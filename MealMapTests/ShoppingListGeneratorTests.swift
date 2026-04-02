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

    func testGeneratorScalesIngredientsByPlannedServingsAndSkipsLeftovers() {
        let generator = ShoppingListGenerator()
        let pantry: [PantryItem] = []

        let pastaBake = Recipe(
            title: "Pasta Bake",
            summary: "Scaled by servings.",
            ingredients: [
                RecipeIngredient(ingredientName: "Pasta", quantity: 200, unit: .gram),
                RecipeIngredient(ingredientName: "Cheddar", quantity: 2, unit: .slice),
            ],
            instructions: "Bake it.",
            tags: ["Dinner"],
            estimatedCost: 8,
            prepTimeMinutes: 30,
            defaultServings: 2
        )

        let freshCookEntry = MealPlanEntry(
            date: .now,
            mealType: .dinner,
            recipeID: pastaBake.id,
            servings: 4
        )

        let leftoverEntry = MealPlanEntry(
            date: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now,
            mealType: .lunch,
            recipeID: pastaBake.id,
            servings: 2,
            leftoversSourceEntryID: freshCookEntry.id
        )

        let results = generator.generate(
            pantryItems: pantry,
            plannedEntries: [freshCookEntry, leftoverEntry],
            recipes: [pastaBake]
        )

        XCTAssertEqual(results.first(where: { $0.name == "Pasta" })?.quantity, 400)
        XCTAssertEqual(results.first(where: { $0.name == "Cheddar" })?.quantity, 4)
        XCTAssertEqual(results.count, 2)
    }

    func testRemainingLeftoverServingsTrackWhatHasAlreadyBeenReused() {
        let metrics = MealPlanMetricsService()
        let sourceEntry = MealPlanEntry(
            date: .now,
            mealType: .dinner,
            recipeID: UUID(),
            servings: 4
        )

        let reusedEntry = MealPlanEntry(
            date: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now,
            mealType: .lunch,
            recipeID: sourceEntry.recipeID,
            servings: 2,
            leftoversSourceEntryID: sourceEntry.id
        )

        XCTAssertEqual(
            metrics.remainingLeftoverServings(for: sourceEntry, entries: [sourceEntry, reusedEntry]),
            2
        )
    }

    func testEligibleLeftoverSourcesSkipMealsWithNoServingsLeft() {
        let metrics = MealPlanMetricsService()
        let sourceEntry = MealPlanEntry(
            date: .now,
            mealType: .dinner,
            recipeID: UUID(),
            servings: 2
        )

        let reusedEntry = MealPlanEntry(
            date: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now,
            mealType: .lunch,
            recipeID: sourceEntry.recipeID,
            servings: 2,
            leftoversSourceEntryID: sourceEntry.id
        )

        let targetDate = Calendar.current.date(byAdding: .day, value: 2, to: .now) ?? .now
        let candidates = metrics.eligibleLeftoverSources(
            for: targetDate,
            entries: [sourceEntry, reusedEntry]
        )

        XCTAssertTrue(candidates.isEmpty)
    }
}
