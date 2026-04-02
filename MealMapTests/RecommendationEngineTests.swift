import XCTest
@testable import MealMap

@MainActor
final class RecommendationEngineTests: XCTestCase {
    func testPantryOnlyFilterReturnsOnlyFullyCoveredRecipes() async {
        let engine = LocalRecommendationEngine()
        let pantry = [
            PantryItem(name: "Rice", quantity: 2, unit: .cup, category: .grains),
            PantryItem(name: "Eggs", quantity: 4, unit: .piece, category: .protein),
        ]

        let readyRecipe = Recipe(
            title: "Egg Rice Bowl",
            summary: "Uses pantry basics.",
            ingredients: [
                RecipeIngredient(ingredientName: "Rice", quantity: 2, unit: .cup),
                RecipeIngredient(ingredientName: "Eggs", quantity: 2, unit: .piece),
            ],
            instructions: "Cook rice.\nCook eggs.\nServe together.",
            tags: ["Budget"],
            estimatedCost: 4,
            prepTimeMinutes: 15
        )

        let incompleteRecipe = Recipe(
            title: "Cheesy Pasta",
            summary: "Needs cheese that is missing.",
            ingredients: [
                RecipeIngredient(ingredientName: "Pasta", quantity: 250, unit: .gram),
                RecipeIngredient(ingredientName: "Cheddar", quantity: 2, unit: .slice),
            ],
            instructions: "Boil pasta.\nAdd cheese.",
            tags: ["Quick"],
            estimatedCost: 6,
            prepTimeMinutes: 20
        )

        let results = await engine.recommend(
            recipes: [readyRecipe, incompleteRecipe],
            pantryItems: pantry,
            budgetFriendlyMode: false,
            onlyUsePantryItems: true
        )

        XCTAssertEqual(results.map(\.recipe.title), ["Egg Rice Bowl"])
        XCTAssertTrue(results.first?.canBeMadeWithWhatIHave == true)
    }

    func testBudgetModeRanksLowerCostRecipeHigherWhenCoverageIsEqual() async {
        let engine = LocalRecommendationEngine()
        let pantry = [
            PantryItem(name: "Rice", quantity: 2, unit: .cup, category: .grains),
        ]

        let lowerCostRecipe = Recipe(
            title: "Budget Bowl",
            summary: "Same pantry match, lower cost.",
            ingredients: [
                RecipeIngredient(ingredientName: "Rice", quantity: 2, unit: .cup),
            ],
            instructions: "Cook rice.",
            tags: ["Budget"],
            estimatedCost: 3,
            prepTimeMinutes: 10
        )

        let higherCostRecipe = Recipe(
            title: "Premium Bowl",
            summary: "Same pantry match, higher cost.",
            ingredients: [
                RecipeIngredient(ingredientName: "Rice", quantity: 2, unit: .cup),
            ],
            instructions: "Cook rice.",
            tags: ["Dinner"],
            estimatedCost: 9,
            prepTimeMinutes: 10
        )

        let results = await engine.recommend(
            recipes: [higherCostRecipe, lowerCostRecipe],
            pantryItems: pantry,
            budgetFriendlyMode: true,
            onlyUsePantryItems: false
        )

        XCTAssertEqual(results.first?.recipe.title, "Budget Bowl")
        XCTAssertGreaterThan(results.first?.matchScore ?? 0, results.last?.matchScore ?? 0)
    }

    func testExpiringIngredientImprovesScore() async {
        let engine = LocalRecommendationEngine()
        let pantry = [
            PantryItem(
                name: "Spinach",
                quantity: 1,
                unit: .bunch,
                category: .produce,
                expirationDate: Calendar.current.date(byAdding: .day, value: 1, to: .now)
            ),
            PantryItem(name: "Pasta", quantity: 250, unit: .gram, category: .grains),
        ]

        let expiringRecipe = Recipe(
            title: "Spinach Pasta",
            summary: "Uses expiring spinach.",
            ingredients: [
                RecipeIngredient(ingredientName: "Spinach", quantity: 1, unit: .bunch),
            ],
            instructions: "Cook spinach.",
            tags: ["Quick"],
            estimatedCost: 5,
            prepTimeMinutes: 10
        )

        let pantryOnlyRecipe = Recipe(
            title: "Plain Pasta",
            summary: "Uses pantry pasta but not expiring items.",
            ingredients: [
                RecipeIngredient(ingredientName: "Pasta", quantity: 250, unit: .gram),
            ],
            instructions: "Cook pasta.",
            tags: ["Quick"],
            estimatedCost: 5,
            prepTimeMinutes: 10
        )

        let results = await engine.recommend(
            recipes: [pantryOnlyRecipe, expiringRecipe],
            pantryItems: pantry,
            budgetFriendlyMode: false,
            onlyUsePantryItems: false
        )

        XCTAssertEqual(results.first?.recipe.title, "Spinach Pasta")
        XCTAssertGreaterThan(results.first?.expiringIngredientCount ?? 0, 0)
    }

    func testFavoriteAndRepeatUsageBoostRecommendationOrder() async {
        let engine = LocalRecommendationEngine()
        let pantry = [
            PantryItem(name: "Rice", quantity: 4, unit: .cup, category: .grains),
        ]

        let favoriteRecipe = Recipe(
            title: "Favorite Bowl",
            summary: "Marked as favorite.",
            ingredients: [
                RecipeIngredient(ingredientName: "Rice", quantity: 2, unit: .cup),
            ],
            instructions: "Cook rice.",
            tags: ["Quick"],
            estimatedCost: 5,
            prepTimeMinutes: 10,
            isFavorite: true
        )

        let regularRecipe = Recipe(
            title: "Regular Bowl",
            summary: "Not favorited.",
            ingredients: [
                RecipeIngredient(ingredientName: "Rice", quantity: 2, unit: .cup),
            ],
            instructions: "Cook rice.",
            tags: ["Quick"],
            estimatedCost: 5,
            prepTimeMinutes: 10
        )

        let plannedEntries = [
            MealPlanEntry(date: .now, mealType: .lunch, recipeID: favoriteRecipe.id),
            MealPlanEntry(date: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now, mealType: .dinner, recipeID: favoriteRecipe.id),
        ]

        let results = await engine.recommend(
            recipes: [regularRecipe, favoriteRecipe],
            pantryItems: pantry,
            plannedEntries: plannedEntries,
            budgetFriendlyMode: false,
            onlyUsePantryItems: false
        )

        XCTAssertEqual(results.first?.recipe.title, "Favorite Bowl")
        XCTAssertTrue(results.first?.favoriteBoostApplied == true)
        XCTAssertTrue(results.first?.repeatBoostApplied == true)
        XCTAssertEqual(results.first?.timesPlanned, 2)
    }
}
