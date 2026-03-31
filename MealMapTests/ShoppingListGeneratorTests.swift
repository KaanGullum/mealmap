import XCTest
@testable import MealMap

@MainActor
final class ShoppingListGeneratorTests: XCTestCase {
    func testGeneratorAggregatesDuplicateMissingIngredientsAcrossRecipes() {
        let generator = ShoppingListGenerator()
        let pantry = [
            PantryItem(name: "Rice", quantity: 1, unit: .cup, category: .grains),
        ]

        let riceRecipeA = Recipe(
            title: "Rice Bowl A",
            summary: "Needs rice and tomatoes.",
            ingredients: [
                RecipeIngredient(ingredientName: "Rice", quantity: 1, unit: .cup),
                RecipeIngredient(ingredientName: "Tomatoes", quantity: 1, unit: .piece),
            ],
            instructions: "Cook and serve.",
            tags: ["Lunch"],
            estimatedCost: 4,
            prepTimeMinutes: 15
        )

        let riceRecipeB = Recipe(
            title: "Rice Bowl B",
            summary: "Needs more rice and tomatoes.",
            ingredients: [
                RecipeIngredient(ingredientName: "Rice", quantity: 1, unit: .cup),
                RecipeIngredient(ingredientName: "Tomatoes", quantity: 2, unit: .piece),
            ],
            instructions: "Cook and serve.",
            tags: ["Dinner"],
            estimatedCost: 5,
            prepTimeMinutes: 20
        )

        let entries = [
            MealPlanEntry(date: .now, mealType: .lunch, recipeID: riceRecipeA.id),
            MealPlanEntry(date: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now, mealType: .dinner, recipeID: riceRecipeB.id),
        ]

        let results = generator.generate(
            pantryItems: pantry,
            plannedEntries: entries,
            recipes: [riceRecipeA, riceRecipeB]
        )

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first(where: { $0.name == "Rice" })?.quantity, 1)
        XCTAssertEqual(results.first(where: { $0.name == "Tomatoes" })?.quantity, 3)
    }

    func testGeneratorSkipsIngredientsAlreadyCoveredByPantry() {
        let generator = ShoppingListGenerator()
        let pantry = [
            PantryItem(name: "Eggs", quantity: 6, unit: .piece, category: .protein),
        ]

        let omelet = Recipe(
            title: "Omelet",
            summary: "Fully covered by pantry eggs.",
            ingredients: [
                RecipeIngredient(ingredientName: "Eggs", quantity: 3, unit: .piece),
            ],
            instructions: "Cook eggs.",
            tags: ["Breakfast"],
            estimatedCost: 2,
            prepTimeMinutes: 10
        )

        let results = generator.generate(
            pantryItems: pantry,
            plannedEntries: [MealPlanEntry(date: .now, mealType: .breakfast, recipeID: omelet.id)],
            recipes: [omelet]
        )

        XCTAssertTrue(results.isEmpty)
    }
}
