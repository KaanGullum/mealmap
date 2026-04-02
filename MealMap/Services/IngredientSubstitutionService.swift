import Foundation

struct IngredientSubstitutionSuggestion: Identifiable, Hashable {
    let id = UUID()
    let substituteName: String
    let detail: String
    let isPantryAvailable: Bool
}

struct MissingIngredientGuidance: Identifiable {
    let ingredientName: String
    let suggestions: [IngredientSubstitutionSuggestion]

    var id: String { ingredientName }
}

struct IngredientSubstitutionService {
    func guidance(
        for missingIngredients: [RecipeIngredient],
        pantryItems: [PantryItem]
    ) -> [MissingIngredientGuidance] {
        let inventory = PantryInventorySnapshot(items: pantryItems)

        return missingIngredients.compactMap { ingredient in
            let suggestions = suggestions(for: ingredient.ingredientName, inventory: inventory)
            guard suggestions.isEmpty == false else {
                return nil
            }

            return MissingIngredientGuidance(
                ingredientName: ingredient.ingredientName,
                suggestions: suggestions
            )
        }
    }

    private func suggestions(
        for ingredientName: String,
        inventory: PantryInventorySnapshot
    ) -> [IngredientSubstitutionSuggestion] {
        let normalizedName = ingredientName.normalizedIngredientName

        guard let definition = substitutionDefinitions.first(where: { definition in
            L10n.variants(for: definition.ingredientKey)
                .map(\.normalizedIngredientName)
                .contains(normalizedName)
        }) else {
            return []
        }

        return definition.suggestions.map { suggestion in
            IngredientSubstitutionSuggestion(
                substituteName: L10n.text(suggestion.nameKey),
                detail: L10n.text(suggestion.detailKey),
                isPantryAvailable: inventory.hasAnyMatch(for: L10n.text(suggestion.nameKey))
            )
        }
    }

    private var substitutionDefinitions: [IngredientSubstitutionDefinition] {
        [
            IngredientSubstitutionDefinition(
                ingredientKey: "Yogurt",
                suggestions: [
                    .init(nameKey: "Labneh", detailKey: "Similar tangy dairy option for bowls and sauces."),
                    .init(nameKey: "Sour Cream", detailKey: "Works as a creamy topping in the same amount.")
                ]
            ),
            IngredientSubstitutionDefinition(
                ingredientKey: "Spinach",
                suggestions: [
                    .init(nameKey: "Arugula", detailKey: "Peppery leafy swap that cooks down quickly."),
                    .init(nameKey: "Kale", detailKey: "Use a little longer cooking time for a sturdier green.")
                ]
            ),
            IngredientSubstitutionDefinition(
                ingredientKey: "Cheddar",
                suggestions: [
                    .init(nameKey: "Mozzarella", detailKey: "Melts well with a milder flavor."),
                    .init(nameKey: "Kashar Cheese", detailKey: "Great local swap for toast, pasta, and skillets.")
                ]
            ),
            IngredientSubstitutionDefinition(
                ingredientKey: "Milk",
                suggestions: [
                    .init(nameKey: "Oat Milk", detailKey: "Keeps sauces creamy with a neutral flavor."),
                    .init(nameKey: "Water and Butter", detailKey: "Use a little butter to replace richness in cooked dishes.")
                ]
            ),
            IngredientSubstitutionDefinition(
                ingredientKey: "Tomatoes",
                suggestions: [
                    .init(nameKey: "Canned Tomatoes", detailKey: "Best cooked swap for sauces, bowls, and skillets."),
                    .init(nameKey: "Roasted Red Peppers", detailKey: "Adds sweetness and acidity in warm dishes.")
                ]
            ),
            IngredientSubstitutionDefinition(
                ingredientKey: "Bread",
                suggestions: [
                    .init(nameKey: "Tortilla", detailKey: "Easy base for wraps, melts, and skillet breakfasts."),
                    .init(nameKey: "Pita", detailKey: "Great for toast-style toppings and grain bowls.")
                ]
            ),
            IngredientSubstitutionDefinition(
                ingredientKey: "Black Beans",
                suggestions: [
                    .init(nameKey: "Kidney Beans", detailKey: "Same canned-bean role in rice bowls and skillets."),
                    .init(nameKey: "Canned Chickpeas", detailKey: "Slightly firmer but still pantry friendly.")
                ]
            ),
        ]
    }
}

private struct IngredientSubstitutionDefinition {
    let ingredientKey: String
    let suggestions: [IngredientSubstitutionEntry]
}

private struct IngredientSubstitutionEntry {
    let nameKey: String
    let detailKey: String
}
