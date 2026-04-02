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
    @State private var recipeToDelete: Recipe?
    @State private var errorMessage: String?
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
                    Toggle(L10n.text("Budget-friendly ranking"), isOn: $budgetFriendlyMode)
                    Toggle(L10n.text("Can be made with what I already have"), isOn: $showOnlyAvailableRecipes)
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
                Section(L10n.text("Recipes")) {
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
                            Button(L10n.text("Delete"), role: .destructive) {
                                recipeToDelete = recommendation.recipe
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(L10n.text("Recipes"))
        .searchable(text: $viewModel.searchText, prompt: L10n.text("Search recipes or tags"))
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
        .alert(L10n.text("Delete Recipe"), isPresented: Binding(
            get: { recipeToDelete != nil },
            set: { if $0 == false { recipeToDelete = nil } }
        ), actions: {
            Button(L10n.text("Cancel"), role: .cancel) {
                recipeToDelete = nil
            }
            Button(L10n.text("Delete"), role: .destructive) {
                if let recipe = recipeToDelete {
                    delete(recipe)
                }
                recipeToDelete = nil
            }
        }, message: {
            Text(L10n.text("This recipe and all its planned meals will be removed. This cannot be undone."))
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

    private var filteredRecommendations: [RecipeRecommendation] {
        viewModel.filteredRecommendations()
    }

    private var refreshKey: Int {
        var hasher = Hasher()
        hasher.combine(recipes.count)
        hasher.combine(pantryItems.count)
        hasher.combine(mealPlanEntries.count)
        for recipe in recipes {
            hasher.combine(recipe.id)
            hasher.combine(recipe.estimatedCost)
            hasher.combine(recipe.isFavorite)
            hasher.combine(recipe.defaultServings)
            hasher.combine(recipe.ingredients.count)
        }
        for item in pantryItems {
            hasher.combine(item.id)
            hasher.combine(item.quantity)
        }
        for entry in mealPlanEntries {
            hasher.combine(entry.id)
            hasher.combine(entry.recipeID)
            hasher.combine(entry.servings)
        }
        hasher.combine(budgetFriendlyMode)
        hasher.combine(showOnlyAvailableRecipes)
        return hasher.finalize()
    }

    private func delete(_ recipe: Recipe) {
        do {
            let recipeID = recipe.id
            for entry in mealPlanEntries where entry.recipeID == recipeID {
                modelContext.delete(entry)
            }
            if let imageName = recipe.imageName {
                RecipeImageStore.delete(named: imageName)
            }
            modelContext.delete(recipe)
            try modelContext.save()
        } catch {
            errorMessage = L10n.text("Unable to delete the recipe right now.")
        }
    }

    private func toggleFavorite(_ recipe: Recipe) {
        do {
            recipe.isFavorite.toggle()
            try modelContext.save()
        } catch {
            errorMessage = L10n.text("Unable to update favorite status.")
        }
    }
}

private struct RecipeListRow: View {
    let recommendation: RecipeRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                RecipeThumbnailView(imageName: recommendation.recipe.imageName)

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
