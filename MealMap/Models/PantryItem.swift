import Foundation
import SwiftData

@Model
final class PantryItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var quantity: Double
    var unit: IngredientUnit
    var category: PantryCategory
    var expirationDate: Date?
    var isStaple: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: IngredientUnit,
        category: PantryCategory,
        expirationDate: Date? = nil,
        isStaple: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.expirationDate = expirationDate
        self.isStaple = isStaple
        self.createdAt = createdAt
    }
}
