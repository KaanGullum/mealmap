import Foundation

struct RecipeRecommendation: Identifiable {
    let recipe: Recipe
    let matchScore: Int
    let matchedIngredientCount: Int
    let totalIngredientCount: Int
    let expiringIngredientCount: Int
    let missingIngredients: [RecipeIngredient]
    let budgetBoostApplied: Bool

    var id: UUID { recipe.id }

    var canBeMadeWithWhatIHave: Bool {
        missingIngredients.isEmpty
    }

    var matchSummary: String {
        L10n.readyIngredients(matched: matchedIngredientCount, total: totalIngredientCount)
    }
}

struct ShoppingListItemDraft: Identifiable, Hashable {
    let id: UUID
    let name: String
    let quantity: Double
    let unit: IngredientUnit

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: IngredientUnit
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
}

struct PantrySummary {
    let totalItems: Int
    let stapleItems: Int
    let expiringSoonItems: Int
}
