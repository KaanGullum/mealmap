import Foundation

struct IngredientCategorizer {
    func categoryTitle(for ingredientName: String, pantryItems: [PantryItem]) -> String {
        if let matchedItem = pantryItems.first(where: { $0.name.normalizedIngredientName == ingredientName.normalizedIngredientName }) {
            return matchedItem.category.title
        }

        let normalized = ingredientName.normalizedIngredientName
        if normalized.contains("milk") || normalized.contains("cheddar") || normalized.contains("yogurt") {
            return PantryCategory.dairy.title
        }
        if normalized.contains("bean") || normalized.contains("chickpea") {
            return PantryCategory.cannedGoods.title
        }
        if normalized.contains("rice") || normalized.contains("pasta") || normalized.contains("bread") || normalized.contains("granola") {
            return PantryCategory.grains.title
        }
        if normalized.contains("egg") {
            return PantryCategory.protein.title
        }
        if normalized.contains("banana") || normalized.contains("spinach") || normalized.contains("tomato") || normalized.contains("garlic") {
            return PantryCategory.produce.title
        }
        return PantryCategory.other.title
    }
}
