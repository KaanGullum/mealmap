import SwiftData
import SwiftUI

@MainActor
struct DashboardView: View {
    @Binding var selectedTab: AppTab
    @Query(sort: \PantryItem.name) private var pantryItems: [PantryItem]
    @Query(sort: \Recipe.title) private var recipes: [Recipe]
    @Query(sort: \MealPlanEntry.date) private var mealPlanEntries: [MealPlanEntry]
    @StateObject private var viewModel: DashboardViewModel
    @State private var showSettings = false
    @AppStorage("budgetFriendlyMode") private var budgetFriendlyMode = false
    @AppStorage("showOnlyAvailableRecipes") private var showOnlyAvailableRecipes = false
    @AppStorage("weeklyBudgetLimitEnabled") private var weeklyBudgetLimitEnabled = false
    @AppStorage("weeklyBudgetLimit") private var weeklyBudgetLimit = 700.0
    private let metricsService = MealPlanMetricsService()

    @MainActor
    init(selectedTab: Binding<AppTab>) {
        self._selectedTab = selectedTab
        _viewModel = StateObject(wrappedValue: DashboardViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                dashboardHero
                expiringSoonSection
                lowStockSection
                quickActionsSection
                suggestionsSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("MealMap")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .task(id: refreshKey) {
            await viewModel.refresh(
                pantryItems: pantryItems,
                recipes: recipes,
                plannedEntries: mealPlanEntries,
                budgetFriendlyMode: budgetFriendlyMode,
                onlyUsePantryItems: showOnlyAvailableRecipes
            )
        }
    }

    private var refreshKey: String {
        let pantryKey = pantryItems.map { item in
            "\(item.id.uuidString)-\(item.quantity)-\(item.expirationDate?.timeIntervalSince1970 ?? 0)"
        }
        .joined(separator: "|")

        let recipeKey = recipes.map { recipe in
            "\(recipe.id.uuidString)-\(recipe.ingredients.count)-\(recipe.estimatedCost)-\(recipe.defaultServings)-\(recipe.isFavorite)"
        }
        .joined(separator: "|")

        let mealPlanKey = mealPlanEntries.map { entry in
            "\(entry.id.uuidString)-\(entry.date.timeIntervalSince1970)-\(entry.recipeID.uuidString)-\(entry.servings)-\(entry.leftoversSourceEntryID?.uuidString ?? "none")"
        }
        .joined(separator: "|")

        return [pantryKey, recipeKey, mealPlanKey, "\(budgetFriendlyMode)", "\(showOnlyAvailableRecipes)", "\(weeklyBudgetLimitEnabled)", "\(weeklyBudgetLimit)"]
            .joined(separator: "#")
    }

    private var dashboardHero: some View {
        let weeklyCost = metricsService.weeklyEstimatedCost(entries: mealPlanEntries, recipes: recipes)
        let remainingBudget = metricsService.remainingBudget(
            budgetLimit: weeklyBudgetLimit,
            entries: mealPlanEntries,
            recipes: recipes
        )

        return VStack(alignment: .leading, spacing: 16) {
            Text("Plan smarter with the pantry you already have.")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("See what needs to be used soon, discover low-cost meals, and build the week without overbuying.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                SummaryMetricCard(
                    title: L10n.text("Pantry Items"),
                    value: "\(viewModel.pantrySummary.totalItems)",
                    systemImage: "cabinet"
                )
                SummaryMetricCard(
                    title: L10n.text("Expiring Soon"),
                    value: "\(viewModel.pantrySummary.expiringSoonItems)",
                    systemImage: "clock.badge"
                )
                SummaryMetricCard(
                    title: L10n.text("Low Stock"),
                    value: "\(viewModel.pantrySummary.lowStockItems)",
                    systemImage: "exclamationmark.circle"
                )
                SummaryMetricCard(
                    title: L10n.text("Planned Meals"),
                    value: "\(viewModel.plannedMealsCount)",
                    systemImage: "calendar"
                )
            }

            if weeklyBudgetLimitEnabled {
                Label(
                    remainingBudget >= 0
                        ? L10n.dashboardBudgetStatus(weeklyCost.currencyText, remainingText: remainingBudget.currencyText)
                        : L10n.dashboardBudgetOverStatus(weeklyCost.currencyText, overAmountText: abs(remainingBudget).currencyText),
                    systemImage: remainingBudget >= 0 ? "wallet.pass.fill" : "exclamationmark.triangle.fill"
                )
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
            }
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [Color.green, Color.teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
    }

    private var expiringSoonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Expiring Soon")
                    .font(.headline)
                Spacer()
                if viewModel.expiringSoonItems.isEmpty == false {
                    Text("Use these first")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if viewModel.expiringSoonItems.isEmpty {
                EmptyStateView(
                    title: L10n.text("Nothing urgent right now"),
                    message: L10n.text("Your pantry is in good shape. Add expiration dates to keep this area useful."),
                    systemImage: "checkmark.seal"
                )
            } else {
                ForEach(Array(viewModel.expiringSoonItems.prefix(4)), id: \.id) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.name)
                                .font(.headline)
                            Text("\(item.quantity.quantityText(unit: item.unit)) • \(item.category.title)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if let expirationDate = item.expirationDate {
                            VStack(alignment: .trailing, spacing: 4) {
                                Label(expirationDate.dayMonthText, systemImage: "calendar")
                                    .font(.caption.weight(.medium))
                                Text(expirationDate.weekdayText)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
    }

    private var lowStockSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Low Stock")
                    .font(.headline)
                Spacer()
                if viewModel.lowStockItems.isEmpty == false {
                    Text("Restock soon")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if viewModel.lowStockItems.isEmpty {
                EmptyStateView(
                    title: L10n.text("No low-stock items"),
                    message: L10n.text("Your pantry quantities still look healthy. As items get lower, they will appear here."),
                    systemImage: "checkmark.circle"
                )
            } else {
                ForEach(Array(viewModel.lowStockItems.prefix(4)), id: \.id) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text(item.name)
                                    .font(.headline)
                                if item.isStaple {
                                    TagChipView(title: L10n.text("Staple"))
                                }
                            }
                            Text(item.category.title)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(item.quantity.quantityText(unit: item.unit))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.orange)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 12) {
                DashboardActionButton(title: L10n.text("Pantry"), systemImage: "plus.circle") {
                    selectedTab = .pantry
                }
                DashboardActionButton(title: L10n.text("Recipes"), systemImage: "fork.knife.circle") {
                    selectedTab = .recipes
                }
                DashboardActionButton(title: L10n.text("Planner"), systemImage: "calendar.badge.plus") {
                    selectedTab = .planner
                }
                DashboardActionButton(title: L10n.text("Settings"), systemImage: "slider.horizontal.3") {
                    showSettings = true
                }
            }
        }
    }

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Suggested Meals")
                        .font(.headline)
                    Text("Ranked by pantry match, expiring ingredients, and budget preferences.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Toggle("Budget", isOn: $budgetFriendlyMode)
                        .toggleStyle(.switch)
                    Toggle("Use what I have", isOn: $showOnlyAvailableRecipes)
                        .toggleStyle(.switch)
                }
                .font(.caption)
                .frame(maxWidth: 170)
            }

            if viewModel.recommendations.isEmpty {
                EmptyStateView(
                    title: L10n.text("No suggestions yet"),
                    message: L10n.text("Add a few pantry items or recipes to unlock local meal recommendations."),
                    systemImage: "sparkles"
                )
            } else {
                ForEach(Array(viewModel.recommendations.prefix(5))) { recommendation in
                    NavigationLink {
                        RecipeDetailView(recipe: recommendation.recipe)
                    } label: {
                        SuggestedMealCard(recommendation: recommendation)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct DashboardActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.title3)
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct SuggestedMealCard: View {
    let recommendation: RecipeRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(recommendation.recipe.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(recommendation.recipe.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                MatchScoreBadgeView(score: recommendation.matchScore)
            }

            HStack(spacing: 12) {
                Label(recommendation.matchSummary, systemImage: "checkmark.circle")
                Label(L10n.minutes(recommendation.recipe.prepTimeMinutes), systemImage: "timer")
                Label(recommendation.recipe.estimatedCost.currencyText, systemImage: MealMapSymbols.cost)
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if recommendation.expiringIngredientCount > 0
                || recommendation.canBeMadeWithWhatIHave
                || recommendation.recipe.isFavorite
                || recommendation.timesPlanned > 0 {
                HStack(spacing: 8) {
                    if recommendation.expiringIngredientCount > 0 {
                        TagChipView(title: L10n.text("Uses expiring items"))
                    }
                    if recommendation.canBeMadeWithWhatIHave {
                        TagChipView(title: L10n.text("Ready now"))
                    }
                    if recommendation.recipe.isFavorite {
                        TagChipView(title: L10n.text("Favorite"))
                    }
                    if recommendation.timesPlanned > 0 {
                        TagChipView(title: L10n.repeatCount(recommendation.timesPlanned))
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DashboardView(selectedTab: .constant(.dashboard))
        }
        .modelContainer(ModelContainerFactory.makePreviewContainer())
    }
}
