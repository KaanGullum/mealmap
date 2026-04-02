import SwiftData
import SwiftUI

@MainActor
struct RecipesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.title) private var recipes: [Recipe]
    @Query(sort: \PantryItem.name) private var pantryItems: [PantryItem]
    @Query(sort: \MealPlanEntry.date) private var mealPlanEntries: [MealPlanEntry]
    @StateObject private var viewModel: RecipesViewModel
    @State private var showAddRecipe = false
    @AppStorage("budgetFriendlyMode") private var budgetFriendlyMode = false
    @AppStorage("showOnlyAvailableRecipes") private var showOnlyAvailableRecipes = false

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: RecipesViewModel())
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Budget-friendly ranking", isOn: $budgetFriendlyMode)
                    Toggle("Can be made with what I already have", isOn: $showOnlyAvailableRecipes)
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }

            if filteredRecommendations.isEmpty {
                Section {
                    EmptyStateView(
                        title: L10n.text("No recipes to show"),
                        message: L10n.text("Add a custom recipe or relax the pantry-only filter to see more ideas."),
                        systemImage: "fork.knife",
                        buttonTitle: L10n.text("Add Recipe")
                    ) {
                        showAddRecipe = true
                    }
                }
            } else {
                Section("Recipes") {
                    ForEach(filteredRecommendations) { recommendation in
                        NavigationLink {
                            RecipeDetailView(recipe: recommendation.recipe)
                        } label: {
                            RecipeListRow(recommendation: recommendation)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                toggleFavorite(recommendation.recipe)
                            } label: {
                                Label(
                                    L10n.text(recommendation.recipe.isFavorite ? "Unfavorite" : "Favorite"),
                                    systemImage: recommendation.recipe.isFavorite ? "star.slash" : "star"
                                )
                            }
                            .tint(.yellow)
                            Button("Delete", role: .destructive) {
                                delete(recommendation.recipe)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Recipes")
        .searchable(text: $viewModel.searchText, prompt: "Search recipes or tags")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddRecipe = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddRecipe) {
            NavigationStack {
                RecipeFormView()
            }
        }
        .task(id: refreshKey) {
            await viewModel.refresh(
                recipes: recipes,
                pantryItems: pantryItems,
                plannedEntries: mealPlanEntries,
                budgetFriendlyMode: budgetFriendlyMode,
                onlyUsePantryItems: showOnlyAvailableRecipes
            )
        }
    }

    private var filteredRecommendations: [RecipeRecommendation] {
        viewModel.filteredRecommendations()
    }

    private var refreshKey: String {
        let recipesKey = recipes.map { recipe in
            "\(recipe.id.uuidString)-\(recipe.ingredients.count)-\(recipe.estimatedCost)-\(recipe.defaultServings)-\(recipe.isFavorite)"
        }
        .joined(separator: "|")

        let pantryKey = pantryItems.map { item in
            "\(item.id.uuidString)-\(item.quantity)"
        }
        .joined(separator: "|")

        let mealPlanKey = mealPlanEntries.map { entry in
            "\(entry.id.uuidString)-\(entry.recipeID.uuidString)-\(entry.servings)-\(entry.leftoversSourceEntryID?.uuidString ?? "none")"
        }
        .joined(separator: "|")

        return [recipesKey, pantryKey, mealPlanKey, "\(budgetFriendlyMode)", "\(showOnlyAvailableRecipes)"]
            .joined(separator: "#")
    }

    private func delete(_ recipe: Recipe) {
        modelContext.delete(recipe)
        try? modelContext.save()
    }

    private func toggleFavorite(_ recipe: Recipe) {
        recipe.isFavorite.toggle()
        try? modelContext.save()
    }
}

private struct RecipeListRow: View {
    let recommendation: RecipeRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(recommendation.recipe.title)
                        .font(.headline)
                    Text(recommendation.recipe.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    if recommendation.recipe.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                    MatchScoreBadgeView(score: recommendation.matchScore)
                }
            }

            HStack(spacing: 12) {
                Label(recommendation.recipe.estimatedCost.currencyText, systemImage: MealMapSymbols.cost)
                Label(L10n.minutes(recommendation.recipe.prepTimeMinutes), systemImage: "timer")
                Label(L10n.servings(recommendation.recipe.defaultServings), systemImage: "person.2")
                Label(recommendation.matchSummary, systemImage: "checkmark.circle")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if recommendation.recipe.tags.isEmpty == false {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recommendation.recipe.tags, id: \.self) { tag in
                            TagChipView(title: tag)
                        }
                    }
                }
            }

            if recommendation.recipe.isFavorite || recommendation.timesPlanned > 0 {
                HStack(spacing: 8) {
                    if recommendation.recipe.isFavorite {
                        TagChipView(title: L10n.text("Favorite"))
                    }
                    if recommendation.timesPlanned > 0 {
                        TagChipView(title: L10n.repeatCount(recommendation.timesPlanned))
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}

struct RecipesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RecipesView()
        }
        .modelContainer(ModelContainerFactory.makePreviewContainer())
    }
}
