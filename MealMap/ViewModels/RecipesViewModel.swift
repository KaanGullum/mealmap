import Combine
import Foundation

@MainActor
final class RecipesViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var recommendations: [RecipeRecommendation] = []

    private let recommendationService: RecipeRecommendationServicing

    init(recommendationService: RecipeRecommendationServicing) {
        self.recommendationService = recommendationService
    }

    convenience init() {
        self.init(recommendationService: LocalRecommendationEngine())
    }

    func refresh(
        recipes: [Recipe],
        pantryItems: [PantryItem],
        plannedEntries: [MealPlanEntry],
        budgetFriendlyMode: Bool,
        onlyUsePantryItems: Bool
    ) async {
        recommendations = await recommendationService.recommend(
            recipes: recipes,
            pantryItems: pantryItems,
            plannedEntries: plannedEntries,
            budgetFriendlyMode: budgetFriendlyMode,
            onlyUsePantryItems: onlyUsePantryItems
        )
    }

    func filteredRecommendations() -> [RecipeRecommendation] {
        guard searchText.isEmpty == false else {
            return recommendations
        }

        return recommendations.filter { recommendation in
            recommendation.recipe.title.localizedCaseInsensitiveContains(searchText)
                || recommendation.recipe.summary.localizedCaseInsensitiveContains(searchText)
                || recommendation.recipe.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
        }
    }
}
