import SwiftData
import SwiftUI

@MainActor
struct WeeklyPlannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealPlanEntry.date) private var mealPlanEntries: [MealPlanEntry]
    @Query(sort: \Recipe.title) private var recipes: [Recipe]
    @Query(sort: \PantryItem.name) private var pantryItems: [PantryItem]
    @Query(sort: \ShoppingListItem.name) private var shoppingListItems: [ShoppingListItem]
    @StateObject private var viewModel: PlannerViewModel
    @State private var selectionContext: PlannerSelectionContext?
    @State private var shoppingListMessage: String?
    @State private var errorMessage: String?
    @AppStorage("weeklyBudgetLimitEnabled") private var weeklyBudgetLimitEnabled = false
    @AppStorage("weeklyBudgetLimit") private var weeklyBudgetLimit = 700.0

    @MainActor
    init() {
        _viewModel = StateObject(
            wrappedValue: PlannerViewModel(
                shoppingListGenerator: ShoppingListGenerator(),
                metricsService: MealPlanMetricsService()
            )
        )
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.text("Build your week"))
                        .font(.headline)
                    Text(L10n.text("Pick recipes for each meal slot, then generate a shopping list for anything still missing."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    let weeklyCost = viewModel.weeklyEstimatedCost(entries: mealPlanEntries, recipes: recipes)
                    let remainingBudget = viewModel.remainingBudget(
                        budgetLimit: weeklyBudgetLimit,
                        entries: mealPlanEntries,
                        recipes: recipes
                    )

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        SummaryMetricCard(
                            title: L10n.text("Planned Meals"),
                            value: "\(mealPlanEntries.count)",
                            systemImage: "calendar"
                        )
                        SummaryMetricCard(
                            title: L10n.text("Weekly Cost"),
                            value: weeklyCost.currencyText,
                            systemImage: MealMapSymbols.cost
                        )

                        if weeklyBudgetLimitEnabled {
                            SummaryMetricCard(
                                title: L10n.text("Budget Remaining"),
                                value: remainingBudget.currencyText,
                                systemImage: "wallet.pass"
                            )
                            SummaryMetricCard(
                                title: L10n.text("Budget Cap"),
                                value: weeklyBudgetLimit.currencyText,
                                systemImage: "target"
                            )
                        }
                    }

                    if weeklyBudgetLimitEnabled {
                        Label(
                            remainingBudget >= 0
                                ? L10n.budgetRemainingStatus(remainingBudget.currencyText)
                                : L10n.budgetOverStatus(abs(remainingBudget).currencyText),
                            systemImage: remainingBudget >= 0 ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
                        )
                        .font(.caption.weight(.medium))
                        .foregroundStyle(remainingBudget >= 0 ? .green : .orange)
                        .padding(.top, 4)
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }

            ForEach(viewModel.weekDates, id: \.self) { date in
                Section(date.formatted(.dateTime.weekday(.wide).day().month())) {
                    ForEach(MealType.allCases) { mealType in
                        plannerMealRow(for: date, mealType: mealType)
                    }
                }
            }

            Section {
                Button {
                    generateShoppingList()
                } label: {
                    Label(L10n.text("Generate Shopping List"), systemImage: "cart.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(L10n.text("Weekly Planner"))
        .sheet(item: $selectionContext) { context in
            let entry = viewModel.entry(for: context.date, mealType: context.mealType, entries: mealPlanEntries)

            MealPlanPickerView(
                date: context.date,
                mealType: context.mealType,
                recipes: recipes,
                plannedEntries: mealPlanEntries,
                currentEntryID: entry?.id,
                selectedRecipeID: entry?.recipeID,
                selectedLeftoverSourceEntryID: entry?.leftoversSourceEntryID,
                onSelectRecipe: { recipe in
                    assignRecipe(recipe, for: context)
                },
                onSelectLeftovers: { sourceEntry in
                    assignLeftovers(sourceEntry, for: context)
                },
                onClear: {
                    clearMeal(for: context)
                }
            )
        }
        .alert(L10n.text("Shopping List Updated"), isPresented: Binding(
            get: { shoppingListMessage != nil },
            set: { isPresented in
                if isPresented == false {
                    shoppingListMessage = nil
                }
            }
        ), actions: {
            Button(L10n.text("OK")) {
                shoppingListMessage = nil
            }
        }, message: {
            Text(shoppingListMessage ?? "")
        })
        .alert(L10n.text("Error"), isPresented: Binding(
            get: { errorMessage != nil },
            set: { if $0 == false { errorMessage = nil } }
        ), actions: {
            Button(L10n.text("OK")) { errorMessage = nil }
        }, message: {
            Text(errorMessage ?? "")
        })
    }

    @ViewBuilder
    private func plannerMealRow(for date: Date, mealType: MealType) -> some View {
        let entry = viewModel.entry(for: date, mealType: mealType, entries: mealPlanEntries)
        let recipe = viewModel.recipe(for: entry, recipes: recipes)
        let leftoverSource = entry.flatMap { viewModel.leftoverSource(for: $0, entries: mealPlanEntries) }
        let leftoverSourceRecipe = viewModel.recipe(for: leftoverSource, recipes: recipes)

        VStack(alignment: .leading, spacing: 10) {
            Button {
                selectionContext = PlannerSelectionContext(date: date, mealType: mealType)
            } label: {
                HStack(alignment: .top) {
                    Label(mealType.title, systemImage: mealType.systemImage)
                        .foregroundStyle(.primary)

                    Spacer()

                    if let recipe, let entry {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(recipe.title)
                                .font(.subheadline.weight(.medium))
                                .multilineTextAlignment(.trailing)

                            if viewModel.isLeftoverEntry(entry) {
                                Text(L10n.text("Uses leftovers"))
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            } else {
                                Text(viewModel.plannedCost(for: entry, recipe: recipe).currencyText)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        Text(L10n.text("Choose recipe"))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)

            if let entry, let recipe {
                HStack(spacing: 12) {
                    Label(L10n.servings(viewModel.servings(for: entry, recipe: recipe)), systemImage: "person.2")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if recipe.isFavorite {
                        TagChipView(title: L10n.text("Favorite"))
                    }

                    if viewModel.isLeftoverEntry(entry) {
                        TagChipView(title: L10n.text("Uses leftovers"))
                    }
                }

                if let leftoverSource, let leftoverSourceRecipe {
                    Text(
                        L10n.leftoverFromEntry(
                            recipeTitle: leftoverSourceRecipe.title,
                            mealType: leftoverSource.mealType.title,
                            dateText: leftoverSource.date.formatted(.dateTime.weekday(.abbreviated).day().month())
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Button {
                        updateServings(for: entry, delta: -1)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.green)
                    }
                    .buttonStyle(.plain)

                    Text(L10n.servings(viewModel.servings(for: entry, recipe: recipe)))
                        .font(.caption.weight(.medium))

                    Button {
                        updateServings(for: entry, delta: 1)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.green)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 6)
    }

    private func assignRecipe(_ recipe: Recipe, for context: PlannerSelectionContext) {
        do {
            try viewModel.assign(
                recipe: recipe,
                for: context.date,
                mealType: context.mealType,
                existingEntries: mealPlanEntries,
                in: modelContext
            )
        } catch {
            errorMessage = L10n.text("Unable to assign the recipe right now.")
        }
    }

    private func assignLeftovers(_ sourceEntry: MealPlanEntry, for context: PlannerSelectionContext) {
        do {
            try viewModel.assignLeftovers(
                from: sourceEntry,
                for: context.date,
                mealType: context.mealType,
                recipes: recipes,
                existingEntries: mealPlanEntries,
                in: modelContext
            )
        } catch {
            errorMessage = L10n.text("Unable to assign leftovers right now.")
        }
    }

    private func clearMeal(for context: PlannerSelectionContext) {
        do {
            try viewModel.clearMeal(
                for: context.date,
                mealType: context.mealType,
                existingEntries: mealPlanEntries,
                in: modelContext
            )
        } catch {
            errorMessage = L10n.text("Unable to clear the meal right now.")
        }
    }

    private func updateServings(for entry: MealPlanEntry, delta: Int) {
        do {
            let newServings = delta > 0 ? min(entry.servings + 1, 12) : max(entry.servings - 1, 1)
            try viewModel.updateServings(
                for: entry,
                servings: newServings,
                in: modelContext
            )
        } catch {
            errorMessage = L10n.text("Unable to update servings right now.")
        }
    }

    private func generateShoppingList() {
        do {
            let count = try viewModel.generateShoppingList(
                pantryItems: pantryItems,
                plannedEntries: mealPlanEntries,
                recipes: recipes,
                existingItems: shoppingListItems,
                in: modelContext
            )
            shoppingListMessage = count == 0
                ? L10n.text("Everything needed for your planned meals is already in the pantry.")
                : L10n.addedMissingItems(count)
        } catch {
            shoppingListMessage = L10n.text("Unable to generate the shopping list right now.")
        }
    }
}

struct WeeklyPlannerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeeklyPlannerView()
        }
        .modelContainer(ModelContainerFactory.makePreviewContainer())
    }
}
