import Foundation

struct IngredientCategorizer {
    func categoryTitle(for ingredientName: String, pantryItems: [PantryItem]) -> String {
        if let matchedItem = pantryItems.first(where: { $0.name.normalizedIngredientName == ingredientName.normalizedIngredientName }) {
            return matchedItem.category.title
        }

        let normalized = ingredientName.normalizedIngredientName
        if containsAny(normalized, tokens: ["milk", "cheddar", "yogurt", "sut", "süt", "kasar", "kaşar", "yogurt", "yoğurt"]) {
            return PantryCategory.dairy.title
        }
        if containsAny(normalized, tokens: ["bean", "beans", "chickpea", "chickpeas", "fasulye", "nohut"]) {
            return PantryCategory.cannedGoods.title
        }
        if containsAny(normalized, tokens: ["rice", "pasta", "bread", "granola", "pirinc", "pirinç", "makarna", "ekmek"]) {
            return PantryCategory.grains.title
        }
        if containsAny(normalized, tokens: ["egg", "eggs", "yumurta"]) {
            return PantryCategory.protein.title
        }
        if containsAny(normalized, tokens: ["banana", "spinach", "tomato", "tomatoes", "garlic", "muz", "ispanak", "domates", "sarimsak", "sarımsak"]) {
            return PantryCategory.produce.title
        }
        return PantryCategory.other.title
    }

    private func containsAny(_ value: String, tokens: [String]) -> Bool {
        tokens.contains { token in
            value.contains(token.normalizedIngredientName)
        }
    }
}
