import Foundation
import SwiftData

@Model
final class RecipeIngredient: Identifiable {
    @Attribute(.unique) var id: UUID
    var ingredientName: String
    var quantity: Double
    var unit: IngredientUnit
    var recipe: Recipe?

    init(
        id: UUID = UUID(),
        ingredientName: String,
        quantity: Double,
        unit: IngredientUnit
    ) {
        self.id = id
        self.ingredientName = ingredientName
        self.quantity = quantity
        self.unit = unit
    }
}
