import Foundation

@MainActor
protocol ShoppingListGenerating {
    func generate(
        pantryItems: [PantryItem],
        plannedEntries: [MealPlanEntry],
        recipes: [Recipe]
    ) -> [ShoppingListItemDraft]
}

@MainActor
struct ShoppingListGenerator: ShoppingListGenerating {
    private let metricsService = MealPlanMetricsService()

    func generate(
        pantryItems: [PantryItem],
        plannedEntries: [MealPlanEntry],
        recipes: [Recipe]
    ) -> [ShoppingListItemDraft] {
        let recipeByID = Dictionary(uniqueKeysWithValues: recipes.map { ($0.id, $0) })
        var requiredQuantities: [ShoppingListKey: Double] = [:]

        for entry in plannedEntries {
            guard
                metricsService.isFreshCookEntry(entry),
                let recipe = recipeByID[entry.recipeID]
            else {
                continue
            }

            let multiplier = metricsService.ingredientMultiplier(for: entry, recipe: recipe)

            for ingredient in recipe.ingredients {
                let key = ShoppingListKey(name: ingredient.ingredientName, unit: ingredient.unit)
                requiredQuantities[key, default: 0] += ingredient.quantity * multiplier
            }
        }

        let inventory = PantryInventorySnapshot(items: pantryItems)

        let drafts = requiredQuantities.compactMap { key, totalRequired -> ShoppingListItemDraft? in
            let available = inventory.quantity(for: key.name, unit: key.unit)
            let missing = totalRequired - available

            guard missing > 0.01 else {
                return nil
            }

            return ShoppingListItemDraft(name: key.name, quantity: missing, unit: key.unit)
        }

        return drafts.sorted {
            if $0.name == $1.name {
                return $0.unit.rawValue < $1.unit.rawValue
            }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }
}

private struct ShoppingListKey: Hashable {
    let name: String
    let unit: IngredientUnit
}
