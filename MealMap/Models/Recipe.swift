import Foundation
import SwiftData

@Model
final class Recipe: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String
    @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.recipe) var ingredients: [RecipeIngredient]
    var instructions: String
    var tags: [String]
    var estimatedCost: Double
    var prepTimeMinutes: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        summary: String,
        ingredients: [RecipeIngredient],
        instructions: String,
        tags: [String],
        estimatedCost: Double,
        prepTimeMinutes: Int,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.ingredients = ingredients
        self.instructions = instructions
        self.tags = tags
        self.estimatedCost = estimatedCost
        self.prepTimeMinutes = prepTimeMinutes
        self.createdAt = createdAt
    }
}
