import Foundation

@MainActor
protocol RecipeRecommendationServicing {
    func recommend(
        recipes: [Recipe],
        pantryItems: [PantryItem],
        budgetFriendlyMode: Bool,
        onlyUsePantryItems: Bool
    ) async -> [RecipeRecommendation]
}

@MainActor
struct LocalRecommendationEngine: RecipeRecommendationServicing {
    func recommend(
        recipes: [Recipe],
        pantryItems: [PantryItem],
        budgetFriendlyMode: Bool,
        onlyUsePantryItems: Bool
    ) async -> [RecipeRecommendation] {
        await Task.yield()

        let inventory = PantryInventorySnapshot(items: pantryItems)
        let costBaseline = max(recipes.map(\.estimatedCost).max() ?? 1, 1)

        let recommendations = recipes.compactMap { recipe -> RecipeRecommendation? in
            let evaluation = evaluate(recipe: recipe, inventory: inventory, costBaseline: costBaseline, budgetFriendlyMode: budgetFriendlyMode)

            if onlyUsePantryItems, evaluation.missingIngredients.isEmpty == false {
                return nil
            }

            return evaluation
        }

        return recommendations.sorted {
            if $0.matchScore == $1.matchScore {
                return $0.recipe.estimatedCost < $1.recipe.estimatedCost
            }
            return $0.matchScore > $1.matchScore
        }
    }

    private func evaluate(
        recipe: Recipe,
        inventory: PantryInventorySnapshot,
        costBaseline: Double,
        budgetFriendlyMode: Bool
    ) -> RecipeRecommendation {
        var matchedIngredients = 0
        var expiringIngredients = 0
        var missingIngredients: [RecipeIngredient] = []

        for ingredient in recipe.ingredients {
            let pantryMatch = inventory.quantity(
                for: ingredient.ingredientName,
                unit: ingredient.unit
            )

            if pantryMatch >= ingredient.quantity {
                matchedIngredients += 1

                if inventory.hasExpiringMatch(for: ingredient.ingredientName, within: 3) {
                    expiringIngredients += 1
                }
            } else {
                missingIngredients.append(ingredient)
            }
        }

        let coverageScore = Int((Double(matchedIngredients) / Double(max(recipe.ingredients.count, 1))) * 65)
        let expiringBonus = expiringIngredients * 10
        let completionBonus = missingIngredients.isEmpty ? 15 : 0
        let budgetBonus = budgetFriendlyMode ? Int(((costBaseline - recipe.estimatedCost) / costBaseline) * 20) : 0
        let totalScore = max(0, coverageScore + expiringBonus + completionBonus + budgetBonus)

        return RecipeRecommendation(
            recipe: recipe,
            matchScore: totalScore,
            matchedIngredientCount: matchedIngredients,
            totalIngredientCount: recipe.ingredients.count,
            expiringIngredientCount: expiringIngredients,
            missingIngredients: missingIngredients,
            budgetBoostApplied: budgetFriendlyMode
        )
    }
}

struct PantryInventorySnapshot {
    private let groupedItems: [String: [PantryItem]]

    init(items: [PantryItem]) {
        self.groupedItems = Dictionary(grouping: items) { item in
            item.name.normalizedIngredientName
        }
    }

    func quantity(for ingredientName: String, unit: IngredientUnit) -> Double {
        groupedItems[ingredientName.normalizedIngredientName, default: []]
            .filter { $0.unit == unit }
            .reduce(0) { $0 + $1.quantity }
    }

    func hasExpiringMatch(for ingredientName: String, within days: Int) -> Bool {
        groupedItems[ingredientName.normalizedIngredientName, default: []]
            .contains { item in
                guard let expirationDate = item.expirationDate else {
                    return false
                }
                return expirationDate.isWithinUpcoming(days: days)
            }
    }
}
