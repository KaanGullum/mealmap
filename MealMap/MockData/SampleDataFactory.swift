import Foundation
import SwiftData

struct AppSeedData {
    let pantryItems: [PantryItem]
    let recipes: [Recipe]
    let mealPlanEntries: [MealPlanEntry]
    let shoppingListItems: [ShoppingListItem]

    func insertAll(into context: ModelContext) {
        pantryItems.forEach(context.insert)
        recipes.forEach(context.insert)
        mealPlanEntries.forEach(context.insert)
        shoppingListItems.forEach(context.insert)

        try? context.save()
    }
}

enum SampleDataFactory {
    static func seedData(referenceDate: Date = .now) -> AppSeedData {
        let pantryItems = samplePantry(referenceDate: referenceDate)
        let recipes = sampleRecipes()

        let weekDates = WeekDateProvider.currentWeekDates(referenceDate: referenceDate)
        let mealPlanEntries = [
            MealPlanEntry(date: weekDates[0], mealType: .dinner, recipeID: recipes[0].id),
            MealPlanEntry(date: weekDates[1], mealType: .lunch, recipeID: recipes[2].id),
            MealPlanEntry(date: weekDates[3], mealType: .dinner, recipeID: recipes[4].id),
        ]

        return AppSeedData(
            pantryItems: pantryItems,
            recipes: recipes,
            mealPlanEntries: mealPlanEntries,
            shoppingListItems: []
        )
    }

    static func samplePantry(referenceDate: Date = .now) -> [PantryItem] {
        [
            PantryItem(name: "Spinach", quantity: 1, unit: .bunch, category: .produce, expirationDate: Calendar.current.date(byAdding: .day, value: 1, to: referenceDate)),
            PantryItem(name: "Tomatoes", quantity: 4, unit: .piece, category: .produce, expirationDate: Calendar.current.date(byAdding: .day, value: 3, to: referenceDate)),
            PantryItem(name: "Milk", quantity: 1, unit: .liter, category: .dairy, expirationDate: Calendar.current.date(byAdding: .day, value: 4, to: referenceDate)),
            PantryItem(name: "Eggs", quantity: 6, unit: .piece, category: .protein, expirationDate: Calendar.current.date(byAdding: .day, value: 5, to: referenceDate)),
            PantryItem(name: "Rice", quantity: 1.5, unit: .kilogram, category: .grains, isStaple: true),
            PantryItem(name: "Pasta", quantity: 500, unit: .gram, category: .grains, isStaple: true),
            PantryItem(name: "Canned Chickpeas", quantity: 2, unit: .can, category: .cannedGoods, isStaple: true),
            PantryItem(name: "Olive Oil", quantity: 500, unit: .milliliter, category: .other, isStaple: true),
            PantryItem(name: "Garlic", quantity: 1, unit: .bunch, category: .produce, expirationDate: Calendar.current.date(byAdding: .day, value: 7, to: referenceDate)),
            PantryItem(name: "Yogurt", quantity: 2, unit: .cup, category: .dairy, expirationDate: Calendar.current.date(byAdding: .day, value: 2, to: referenceDate)),
            PantryItem(name: "Cheddar", quantity: 8, unit: .slice, category: .dairy, expirationDate: Calendar.current.date(byAdding: .day, value: 8, to: referenceDate)),
            PantryItem(name: "Black Beans", quantity: 1, unit: .can, category: .cannedGoods, isStaple: true),
        ]
    }

    static func sampleRecipes() -> [Recipe] {
        [
            Recipe(
                title: "Creamy Spinach Pasta",
                summary: "Fast weeknight pasta that uses up spinach and dairy staples.",
                ingredients: [
                    RecipeIngredient(ingredientName: "Pasta", quantity: 250, unit: .gram),
                    RecipeIngredient(ingredientName: "Spinach", quantity: 1, unit: .bunch),
                    RecipeIngredient(ingredientName: "Milk", quantity: 250, unit: .milliliter),
                    RecipeIngredient(ingredientName: "Garlic", quantity: 0.5, unit: .bunch),
                    RecipeIngredient(ingredientName: "Cheddar", quantity: 4, unit: .slice),
                ],
                instructions: """
                Boil the pasta until tender.
                Saute garlic, add spinach, and let it wilt.
                Stir in milk and cheddar to form a quick sauce.
                Toss the pasta with the sauce and serve warm.
                """,
                tags: ["Quick", "Vegetarian", "Budget"],
                estimatedCost: 6.50,
                prepTimeMinutes: 20
            ),
            Recipe(
                title: "Chickpea Tomato Bowls",
                summary: "Pantry-friendly grain bowl with tomatoes and yogurt sauce.",
                ingredients: [
                    RecipeIngredient(ingredientName: "Rice", quantity: 1.5, unit: .cup),
                    RecipeIngredient(ingredientName: "Canned Chickpeas", quantity: 1, unit: .can),
                    RecipeIngredient(ingredientName: "Tomatoes", quantity: 2, unit: .piece),
                    RecipeIngredient(ingredientName: "Yogurt", quantity: 1, unit: .cup),
                    RecipeIngredient(ingredientName: "Garlic", quantity: 0.25, unit: .bunch),
                ],
                instructions: """
                Cook the rice until fluffy.
                Warm chickpeas with chopped tomatoes and garlic.
                Spoon over rice and finish with yogurt.
                """,
                tags: ["Meal Prep", "Budget", "High Protein"],
                estimatedCost: 5.25,
                prepTimeMinutes: 25
            ),
            Recipe(
                title: "Veggie Fried Rice",
                summary: "Budget-friendly fried rice built around eggs and leftover produce.",
                ingredients: [
                    RecipeIngredient(ingredientName: "Rice", quantity: 2, unit: .cup),
                    RecipeIngredient(ingredientName: "Eggs", quantity: 3, unit: .piece),
                    RecipeIngredient(ingredientName: "Spinach", quantity: 0.5, unit: .bunch),
                    RecipeIngredient(ingredientName: "Tomatoes", quantity: 1, unit: .piece),
                    RecipeIngredient(ingredientName: "Olive Oil", quantity: 1, unit: .tablespoon),
                ],
                instructions: """
                Scramble the eggs and set aside.
                Pan-fry vegetables in olive oil.
                Add cooked rice, then fold the eggs back in and season.
                """,
                tags: ["Quick", "Budget", "Use What You Have"],
                estimatedCost: 4.75,
                prepTimeMinutes: 18
            ),
            Recipe(
                title: "Tomato Egg Toasts",
                summary: "Simple breakfast-for-dinner option with pantry staples.",
                ingredients: [
                    RecipeIngredient(ingredientName: "Eggs", quantity: 2, unit: .piece),
                    RecipeIngredient(ingredientName: "Tomatoes", quantity: 2, unit: .piece),
                    RecipeIngredient(ingredientName: "Cheddar", quantity: 2, unit: .slice),
                    RecipeIngredient(ingredientName: "Bread", quantity: 4, unit: .slice),
                ],
                instructions: """
                Toast the bread slices.
                Cook tomatoes and eggs together in a skillet.
                Layer over toast with cheddar and serve.
                """,
                tags: ["Breakfast", "Quick"],
                estimatedCost: 3.90,
                prepTimeMinutes: 15
            ),
            Recipe(
                title: "Black Bean Rice Skillet",
                summary: "Budget dinner with pantry beans, rice, and melted cheddar.",
                ingredients: [
                    RecipeIngredient(ingredientName: "Rice", quantity: 1.5, unit: .cup),
                    RecipeIngredient(ingredientName: "Black Beans", quantity: 1, unit: .can),
                    RecipeIngredient(ingredientName: "Tomatoes", quantity: 2, unit: .piece),
                    RecipeIngredient(ingredientName: "Cheddar", quantity: 4, unit: .slice),
                    RecipeIngredient(ingredientName: "Olive Oil", quantity: 1, unit: .tablespoon),
                ],
                instructions: """
                Cook rice and keep warm.
                Simmer beans and tomatoes together.
                Fold in rice, top with cheddar, and finish in the skillet.
                """,
                tags: ["Budget", "Meal Prep", "Comfort Food"],
                estimatedCost: 5.10,
                prepTimeMinutes: 22
            ),
            Recipe(
                title: "Yogurt Fruit Parfait",
                summary: "Customizable breakfast recipe ready for future nutrition tracking.",
                ingredients: [
                    RecipeIngredient(ingredientName: "Yogurt", quantity: 1, unit: .cup),
                    RecipeIngredient(ingredientName: "Granola", quantity: 1, unit: .cup),
                    RecipeIngredient(ingredientName: "Banana", quantity: 1, unit: .piece),
                ],
                instructions: """
                Layer yogurt, granola, and sliced banana in a glass.
                Serve immediately.
                """,
                tags: ["Breakfast", "Quick"],
                estimatedCost: 4.40,
                prepTimeMinutes: 5
            ),
        ]
    }
}
