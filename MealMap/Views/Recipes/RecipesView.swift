import SwiftData
import SwiftUI

struct RecipesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.title) private var recipes: [Recipe]
    @Query(sort: \PantryItem.name) private var pantryItems: [PantryItem]
    @StateObject private var viewModel = RecipesViewModel()
    @State private var showAddRecipe = false
    @AppStorage("budgetFriendlyMode") private var budgetFriendlyMode = false
    @AppStorage("showOnlyAvailableRecipes") private var showOnlyAvailableRecipes = false

    init() {}

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
                        title: "No recipes to show",
                        message: "Add a custom recipe or relax the pantry-only filter to see more ideas.",
                        systemImage: "fork.knife",
                        buttonTitle: "Add Recipe"
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
            "\(recipe.id.uuidString)-\(recipe.ingredients.count)-\(recipe.estimatedCost)"
        }
        .joined(separator: "|")

        let pantryKey = pantryItems.map { item in
            "\(item.id.uuidString)-\(item.quantity)"
        }
        .joined(separator: "|")

        return [recipesKey, pantryKey, "\(budgetFriendlyMode)", "\(showOnlyAvailableRecipes)"]
            .joined(separator: "#")
    }

    private func delete(_ recipe: Recipe) {
        modelContext.delete(recipe)
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
                MatchScoreBadgeView(score: recommendation.matchScore)
            }

            HStack(spacing: 12) {
                Label(recommendation.recipe.estimatedCost.currencyText, systemImage: "dollarsign.circle")
                Label("\(recommendation.recipe.prepTimeMinutes) min", systemImage: "timer")
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
