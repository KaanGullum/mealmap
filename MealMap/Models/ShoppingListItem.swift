import Foundation
import SwiftData

@Model
final class ShoppingListItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var quantity: Double
    var unit: IngredientUnit
    var isChecked: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: IngredientUnit,
        isChecked: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.isChecked = isChecked
        self.createdAt = createdAt
    }
}
