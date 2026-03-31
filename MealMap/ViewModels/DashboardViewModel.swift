import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var pantrySummary = PantrySummary(totalItems: 0, stapleItems: 0, expiringSoonItems: 0)
    @Published private(set) var expiringSoonItems: [PantryItem] = []
    @Published private(set) var recommendations: [RecipeRecommendation] = []
    @Published private(set) var plannedMealsCount = 0

    private let recommendationService: RecipeRecommendationServicing

    init(recommendationService: RecipeRecommendationServicing) {
        self.recommendationService = recommendationService
    }

    convenience init() {
        self.init(recommendationService: LocalRecommendationEngine())
    }

    func refresh(
        pantryItems: [PantryItem],
        recipes: [Recipe],
        plannedEntries: [MealPlanEntry],
        budgetFriendlyMode: Bool,
        onlyUsePantryItems: Bool
    ) async {
        pantrySummary = PantrySummary(
            totalItems: pantryItems.count,
            stapleItems: pantryItems.filter(\.isStaple).count,
            expiringSoonItems: pantryItems.filter { item in
                guard let expirationDate = item.expirationDate else {
                    return false
                }
                return expirationDate.isWithinUpcoming(days: 3)
            }.count
        )

        expiringSoonItems = pantryItems
            .filter { item in
                guard let expirationDate = item.expirationDate else {
                    return false
                }
                return expirationDate.isWithinUpcoming(days: 5)
            }
            .sorted {
                ($0.expirationDate ?? .distantFuture) < ($1.expirationDate ?? .distantFuture)
            }

        plannedMealsCount = plannedEntries.count
        recommendations = await recommendationService.recommend(
            recipes: recipes,
            pantryItems: pantryItems,
            budgetFriendlyMode: budgetFriendlyMode,
            onlyUsePantryItems: onlyUsePantryItems
        )
    }
}
