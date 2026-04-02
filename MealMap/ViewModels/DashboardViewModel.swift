import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var pantrySummary = PantrySummary(totalItems: 0, stapleItems: 0, expiringSoonItems: 0, lowStockItems: 0)
    @Published private(set) var expiringSoonItems: [PantryItem] = []
    @Published private(set) var lowStockItems: [PantryItem] = []
    @Published private(set) var recommendations: [RecipeRecommendation] = []
    @Published private(set) var plannedMealsCount = 0

    private let recommendationService: RecipeRecommendationServicing
    private let pantryInsightService: PantryInsightService

    init(
        recommendationService: RecipeRecommendationServicing,
        pantryInsightService: PantryInsightService = PantryInsightService()
    ) {
        self.recommendationService = recommendationService
        self.pantryInsightService = pantryInsightService
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
        let lowStockItems = pantryInsightService.lowStockItems(from: pantryItems)
        pantrySummary = PantrySummary(
            totalItems: pantryItems.count,
            stapleItems: pantryItems.filter(\.isStaple).count,
            expiringSoonItems: pantryItems.filter { item in
                guard let expirationDate = item.expirationDate else {
                    return false
                }
                return expirationDate.isWithinUpcoming(days: 3)
            }.count,
            lowStockItems: lowStockItems.count
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

        self.lowStockItems = lowStockItems

        plannedMealsCount = plannedEntries.count
        recommendations = await recommendationService.recommend(
            recipes: recipes,
            pantryItems: pantryItems,
            plannedEntries: plannedEntries,
            budgetFriendlyMode: budgetFriendlyMode,
            onlyUsePantryItems: onlyUsePantryItems
        )
    }
}
