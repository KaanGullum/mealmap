import Combine
import Foundation
import SwiftData

enum RecipeFormSaveError: LocalizedError {
    case photoSaveFailed

    var errorDescription: String? {
        switch self {
        case .photoSaveFailed:
            return L10n.text("Unable to save the recipe photo right now.")
        }
    }
}

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
    @Published var defaultServings = 2
    @Published var isFavorite = false
    @Published var ingredientDrafts: [EditableRecipeIngredient] = [
        EditableRecipeIngredient(),
        EditableRecipeIngredient()
    ]
    @Published var selectedImageData: Data?
    @Published var existingImageName: String?
    @Published var imageRemoved = false

    private let existingRecipe: Recipe?

    init(recipe: Recipe? = nil) {
        self.existingRecipe = recipe

        if let recipe {
            self.title = recipe.title
            self.summary = recipe.summary
            self.instructions = recipe.instructions
            self.tagsText = recipe.tags.joined(separator: ", ")
            self.estimatedCost = recipe.estimatedCost
            self.prepTimeMinutes = recipe.prepTimeMinutes
            self.defaultServings = recipe.defaultServings
            self.isFavorite = recipe.isFavorite
            self.existingImageName = recipe.imageName
            self.ingredientDrafts = recipe.ingredients.map { ingredient in
                EditableRecipeIngredient(
                    ingredientName: ingredient.ingredientName,
                    quantity: ingredient.quantity,
                    unit: ingredient.unit
                )
            }
            if self.ingredientDrafts.isEmpty {
                self.ingredientDrafts = [EditableRecipeIngredient()]
            }
        }
    }

    var formTitle: String {
        existingRecipe == nil ? L10n.text("Add Recipe") : L10n.text("Edit Recipe")
    }

    var canSave: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && ingredientDrafts.contains(where: { $0.ingredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false })
    }

    var hasImage: Bool {
        if imageRemoved { return false }
        return selectedImageData != nil || existingImageName != nil
    }

    func removeImage() {
        selectedImageData = nil
        imageRemoved = true
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

        if let existingRecipe {
            let previousImageName = existingRecipe.imageName

            existingRecipe.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            existingRecipe.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
            existingRecipe.instructions = instructions.trimmingCharacters(in: .whitespacesAndNewlines)
            existingRecipe.tags = tags
            existingRecipe.estimatedCost = estimatedCost
            existingRecipe.prepTimeMinutes = prepTimeMinutes
            existingRecipe.defaultServings = max(defaultServings, 1)
            existingRecipe.isFavorite = isFavorite

            for oldIngredient in existingRecipe.ingredients {
                context.delete(oldIngredient)
            }
            existingRecipe.ingredients = trimmedIngredients

            var replacementImageName: String?
            if let imageData = selectedImageData {
                do {
                    replacementImageName = try RecipeImageStore.save(imageData: imageData, for: existingRecipe.id)
                } catch {
                    throw RecipeFormSaveError.photoSaveFailed
                }
            } else if imageRemoved {
                replacementImageName = nil
            }

            if selectedImageData != nil || imageRemoved {
                existingRecipe.imageName = replacementImageName
            }

            do {
                try context.save()
            } catch {
                existingRecipe.imageName = previousImageName
                if let replacementImageName, replacementImageName != previousImageName {
                    RecipeImageStore.delete(named: replacementImageName)
                }
                throw error
            }

            if imageRemoved, let previousImageName {
                RecipeImageStore.delete(named: previousImageName)
            } else if let replacementImageName, let previousImageName, replacementImageName != previousImageName {
                RecipeImageStore.delete(named: previousImageName)
            }
        } else {
            let recipeID = UUID()
            var savedImageName: String?

            if let imageData = selectedImageData {
                do {
                    savedImageName = try RecipeImageStore.save(imageData: imageData, for: recipeID)
                } catch {
                    throw RecipeFormSaveError.photoSaveFailed
                }
            }

            let recipe = Recipe(
                id: recipeID,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                summary: summary.trimmingCharacters(in: .whitespacesAndNewlines),
                ingredients: trimmedIngredients,
                instructions: instructions.trimmingCharacters(in: .whitespacesAndNewlines),
                tags: tags,
                estimatedCost: estimatedCost,
                prepTimeMinutes: prepTimeMinutes,
                defaultServings: max(defaultServings, 1),
                isFavorite: isFavorite,
                imageName: savedImageName
            )
            context.insert(recipe)

            do {
                try context.save()
            } catch {
                if let savedImageName {
                    RecipeImageStore.delete(named: savedImageName)
                }
                context.delete(recipe)
                throw error
            }
        }
    }
}
