import Combine
import Foundation
import SwiftData

struct EditableRecipeIngredient: Identifiable {
    let id: UUID
    var ingredientName: String
    var quantity: Double
    var unit: IngredientUnit

    init(
        id: UUID = UUID(),
        ingredientName: String = "",
        quantity: Double = 1,
        unit: IngredientUnit = .piece
    ) {
        self.id = id
        self.ingredientName = ingredientName
        self.quantity = quantity
        self.unit = unit
    }
}

@MainActor
final class RecipeFormViewModel: ObservableObject {
    @Published var title = ""
    @Published var summary = ""
    @Published var instructions = ""
    @Published var tagsText = ""
    @Published var estimatedCost = 5.0
    @Published var prepTimeMinutes = 20
    @Published var ingredientDrafts: [EditableRecipeIngredient] = [
        EditableRecipeIngredient(),
        EditableRecipeIngredient()
    ]

    var canSave: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && ingredientDrafts.contains(where: { $0.ingredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false })
    }

    func addIngredientDraft() {
        ingredientDrafts.append(EditableRecipeIngredient())
    }

    func removeIngredientDraft(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            ingredientDrafts.remove(at: index)
        }
        if ingredientDrafts.isEmpty {
            ingredientDrafts.append(EditableRecipeIngredient())
        }
    }

    func save(in context: ModelContext) throws {
        let trimmedIngredients = ingredientDrafts
            .filter { $0.ingredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
            .map { draft in
                RecipeIngredient(
                    ingredientName: draft.ingredientName.trimmingCharacters(in: .whitespacesAndNewlines),
                    quantity: draft.quantity,
                    unit: draft.unit
                )
            }

        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        let recipe = Recipe(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            summary: summary.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: trimmedIngredients,
            instructions: instructions.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: tags,
            estimatedCost: estimatedCost,
            prepTimeMinutes: prepTimeMinutes
        )

        context.insert(recipe)
        try context.save()
    }
}
