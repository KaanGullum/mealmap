import Foundation

struct PantryInsightService {
    func lowStockItems(from pantryItems: [PantryItem]) -> [PantryItem] {
        pantryItems
            .filter { item in
                item.quantity <= threshold(for: item.unit)
            }
            .sorted { lhs, rhs in
                if lhs.isStaple != rhs.isStaple {
                    return lhs.isStaple && rhs.isStaple == false
                }

                if lhs.quantity == rhs.quantity {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }

                return lhs.quantity < rhs.quantity
            }
    }

    func threshold(for unit: IngredientUnit) -> Double {
        switch unit {
        case .piece: 2
        case .gram: 250
        case .kilogram: 0.5
        case .milliliter: 300
        case .liter: 1
        case .cup: 1
        case .tablespoon: 2
        case .teaspoon: 2
        case .can: 1
        case .pack: 1
        case .slice: 2
        case .bunch: 1
        case .loaf: 1
        }
    }
}
