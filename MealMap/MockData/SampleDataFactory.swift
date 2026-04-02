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

struct SamplePantryDefinition {
    let id: UUID
    let nameKey: String
    let quantity: Double
    let unit: IngredientUnit
    let category: PantryCategory
    let expirationOffsetDays: Int?
    let isStaple: Bool
}

struct SampleRecipeIngredientDefinition {
    let ingredientKey: String
    let quantity: Double
    let unit: IngredientUnit
}

struct SampleRecipeDefinition {
    let id: UUID
    let titleKey: String
    let summaryKey: String
    let ingredients: [SampleRecipeIngredientDefinition]
    let instructionKeys: [String]
    let tagKeys: [String]
    let estimatedCost: Double
    let prepTimeMinutes: Int
    let defaultServings: Int
    let isFavorite: Bool
}

struct SampleMealPlanEntryDefinition {
    let id: UUID
    let dateIndex: Int
    let mealType: MealType
    let recipeID: UUID
    let servings: Int
    let leftoversSourceEntryID: UUID?
}

enum SampleDataFactory {
    static let pantryDefinitions: [SamplePantryDefinition] = [
        SamplePantryDefinition(id: sampleID("5EED0000-0000-0000-0000-000000000001"), nameKey: "Spinach", quantity: 1, unit: .bunch, category: .produce, expirationOffsetDays: 1, isStaple: false),
        SamplePantryDefinition(id: sampleID("5EED0000-0000-0000-0000-000000000002"), nameKey: "Tomatoes", quantity: 4, unit: .piece, category: .produce, expirationOffsetDays: 3, isStaple: false),
        SamplePantryDefinition(id: sampleID("5EED0000-0000-0000-0000-000000000003"), nameKey: "Milk", quantity: 1, unit: .liter, category: .dairy, expirationOffsetDays: 4, isStaple: false),
        SamplePantryDefinition(id: sampleID("5EED0000-0000-0000-0000-000000000004"), nameKey: "Eggs", quantity: 6, unit: .piece, category: .protein, expirationOffsetDays: 5, isStaple: false),
        SamplePantryDefinition(id: sampleID("5EED0000-0000-0000-0000-000000000005"), nameKey: "Rice", quantity: 1.5, unit: .kilogram, category: .grains, expirationOffsetDays: nil, isStaple: true),
        SamplePantryDefinition(id: sampleID("5EED0000-0000-0000-0000-000000000006"), nameKey: "Pasta", quantity: 500, unit: .gram, category: .grains, expirationOffsetDays: nil, isStaple: true),
        SamplePantryDefinition(id: sampleID("5EED0000-0000-0000-0000-000000000007"), nameKey: "Canned Chickpeas", quantity: 2, unit: .can, category: .cannedGoods, expirationOffsetDays: nil, isStaple: true),
        SamplePantryDefinition(id: sampleID("5EED0000-0000-0000-0000-000000000008"), nameKey: "Olive Oil", quantity: 500, unit: .milliliter, category: .other, expirationOffsetDays: nil, isStaple: true),
        SamplePantryDefinition(id: sampleID("5EED0000-0000-0000-0000-000000000009"), nameKey: "Garlic", quantity: 1, unit: .bunch, category: .produce, expirationOffsetDays: 7, isStaple: false),
        SamplePantryDefinition(id: sampleID("5EED0000-0000-0000-0000-00000000000A"), nameKey: "Yogurt", quantity: 2, unit: .cup, category: .dairy, expirationOffsetDays: 2, isStaple: false),
        SamplePantryDefinition(id: sampleID("5EED0000-0000-0000-0000-00000000000B"), nameKey: "Cheddar", quantity: 8, unit: .slice, category: .dairy, expirationOffsetDays: 8, isStaple: false),
        SamplePantryDefinition(id: sampleID("5EED0000-0000-0000-0000-00000000000C"), nameKey: "Black Beans", quantity: 1, unit: .can, category: .cannedGoods, expirationOffsetDays: nil, isStaple: true),
    ]

    static let recipeDefinitions: [SampleRecipeDefinition] = [
        SampleRecipeDefinition(
            id: sampleID("5EED1000-0000-0000-0000-000000000001"),
            titleKey: "Creamy Spinach Pasta",
            summaryKey: "Fast weeknight pasta that uses up spinach and dairy staples.",
            ingredients: [
                SampleRecipeIngredientDefinition(ingredientKey: "Pasta", quantity: 250, unit: .gram),
                SampleRecipeIngredientDefinition(ingredientKey: "Spinach", quantity: 1, unit: .bunch),
                SampleRecipeIngredientDefinition(ingredientKey: "Milk", quantity: 250, unit: .milliliter),
                SampleRecipeIngredientDefinition(ingredientKey: "Garlic", quantity: 0.5, unit: .bunch),
                SampleRecipeIngredientDefinition(ingredientKey: "Cheddar", quantity: 4, unit: .slice),
            ],
            instructionKeys: [
                "Boil the pasta until tender.",
                "Saute garlic, add spinach, and let it wilt.",
                "Stir in milk and cheddar to form a quick sauce.",
                "Toss the pasta with the sauce and serve warm."
            ],
            tagKeys: ["Quick", "Vegetarian", "Budget"],
            estimatedCost: 6.50,
            prepTimeMinutes: 20,
            defaultServings: 4,
            isFavorite: true
        ),
        SampleRecipeDefinition(
            id: sampleID("5EED1000-0000-0000-0000-000000000002"),
            titleKey: "Chickpea Tomato Bowls",
            summaryKey: "Pantry-friendly grain bowl with tomatoes and yogurt sauce.",
            ingredients: [
                SampleRecipeIngredientDefinition(ingredientKey: "Rice", quantity: 1.5, unit: .cup),
                SampleRecipeIngredientDefinition(ingredientKey: "Canned Chickpeas", quantity: 1, unit: .can),
                SampleRecipeIngredientDefinition(ingredientKey: "Tomatoes", quantity: 2, unit: .piece),
                SampleRecipeIngredientDefinition(ingredientKey: "Yogurt", quantity: 1, unit: .cup),
                SampleRecipeIngredientDefinition(ingredientKey: "Garlic", quantity: 0.25, unit: .bunch),
            ],
            instructionKeys: [
                "Cook the rice until fluffy.",
                "Warm chickpeas with chopped tomatoes and garlic.",
                "Spoon over rice and finish with yogurt."
            ],
            tagKeys: ["Meal Prep", "Budget", "High Protein"],
            estimatedCost: 5.25,
            prepTimeMinutes: 25,
            defaultServings: 3,
            isFavorite: true
        ),
        SampleRecipeDefinition(
            id: sampleID("5EED1000-0000-0000-0000-000000000003"),
            titleKey: "Veggie Fried Rice",
            summaryKey: "Budget-friendly fried rice built around eggs and leftover produce.",
            ingredients: [
                SampleRecipeIngredientDefinition(ingredientKey: "Rice", quantity: 2, unit: .cup),
                SampleRecipeIngredientDefinition(ingredientKey: "Eggs", quantity: 3, unit: .piece),
                SampleRecipeIngredientDefinition(ingredientKey: "Spinach", quantity: 0.5, unit: .bunch),
                SampleRecipeIngredientDefinition(ingredientKey: "Tomatoes", quantity: 1, unit: .piece),
                SampleRecipeIngredientDefinition(ingredientKey: "Olive Oil", quantity: 1, unit: .tablespoon),
            ],
            instructionKeys: [
                "Scramble the eggs and set aside.",
                "Pan-fry vegetables in olive oil.",
                "Add cooked rice, then fold the eggs back in and season."
            ],
            tagKeys: ["Quick", "Budget", "Use What You Have"],
            estimatedCost: 4.75,
            prepTimeMinutes: 18,
            defaultServings: 2,
            isFavorite: false
        ),
        SampleRecipeDefinition(
            id: sampleID("5EED1000-0000-0000-0000-000000000004"),
            titleKey: "Tomato Egg Toasts",
            summaryKey: "Simple breakfast-for-dinner option with pantry staples.",
            ingredients: [
                SampleRecipeIngredientDefinition(ingredientKey: "Eggs", quantity: 2, unit: .piece),
                SampleRecipeIngredientDefinition(ingredientKey: "Tomatoes", quantity: 2, unit: .piece),
                SampleRecipeIngredientDefinition(ingredientKey: "Cheddar", quantity: 2, unit: .slice),
                SampleRecipeIngredientDefinition(ingredientKey: "Bread", quantity: 4, unit: .slice),
            ],
            instructionKeys: [
                "Toast the bread slices.",
                "Cook tomatoes and eggs together in a skillet.",
                "Layer over toast with cheddar and serve."
            ],
            tagKeys: ["Breakfast", "Quick"],
            estimatedCost: 3.90,
            prepTimeMinutes: 15,
            defaultServings: 2,
            isFavorite: false
        ),
        SampleRecipeDefinition(
            id: sampleID("5EED1000-0000-0000-0000-000000000005"),
            titleKey: "Black Bean Rice Skillet",
            summaryKey: "Budget dinner with pantry beans, rice, and melted cheddar.",
            ingredients: [
                SampleRecipeIngredientDefinition(ingredientKey: "Rice", quantity: 1.5, unit: .cup),
                SampleRecipeIngredientDefinition(ingredientKey: "Black Beans", quantity: 1, unit: .can),
                SampleRecipeIngredientDefinition(ingredientKey: "Tomatoes", quantity: 2, unit: .piece),
                SampleRecipeIngredientDefinition(ingredientKey: "Cheddar", quantity: 4, unit: .slice),
                SampleRecipeIngredientDefinition(ingredientKey: "Olive Oil", quantity: 1, unit: .tablespoon),
            ],
            instructionKeys: [
                "Cook rice and keep warm.",
                "Simmer beans and tomatoes together.",
                "Fold in rice, top with cheddar, and finish in the skillet."
            ],
            tagKeys: ["Budget", "Meal Prep", "Comfort Food"],
            estimatedCost: 5.10,
            prepTimeMinutes: 22,
            defaultServings: 4,
            isFavorite: true
        ),
        SampleRecipeDefinition(
            id: sampleID("5EED1000-0000-0000-0000-000000000006"),
            titleKey: "Yogurt Fruit Parfait",
            summaryKey: "Customizable breakfast recipe ready for future nutrition tracking.",
            ingredients: [
                SampleRecipeIngredientDefinition(ingredientKey: "Yogurt", quantity: 1, unit: .cup),
                SampleRecipeIngredientDefinition(ingredientKey: "Granola", quantity: 1, unit: .cup),
                SampleRecipeIngredientDefinition(ingredientKey: "Banana", quantity: 1, unit: .piece),
            ],
            instructionKeys: [
                "Layer yogurt, granola, and sliced banana in a glass.",
                "Serve immediately."
            ],
            tagKeys: ["Breakfast", "Quick"],
            estimatedCost: 4.40,
            prepTimeMinutes: 5,
            defaultServings: 2,
            isFavorite: false
        ),
    ]

    static let mealPlanEntryDefinitions: [SampleMealPlanEntryDefinition] = [
        SampleMealPlanEntryDefinition(
            id: sampleID("5EED2000-0000-0000-0000-000000000001"),
            dateIndex: 0,
            mealType: .dinner,
            recipeID: sampleID("5EED1000-0000-0000-0000-000000000001"),
            servings: 4,
            leftoversSourceEntryID: nil
        ),
        SampleMealPlanEntryDefinition(
            id: sampleID("5EED2000-0000-0000-0000-000000000002"),
            dateIndex: 1,
            mealType: .lunch,
            recipeID: sampleID("5EED1000-0000-0000-0000-000000000001"),
            servings: 2,
            leftoversSourceEntryID: sampleID("5EED2000-0000-0000-0000-000000000001")
        ),
        SampleMealPlanEntryDefinition(
            id: sampleID("5EED2000-0000-0000-0000-000000000003"),
            dateIndex: 2,
            mealType: .dinner,
            recipeID: sampleID("5EED1000-0000-0000-0000-000000000003"),
            servings: 2,
            leftoversSourceEntryID: nil
        ),
        SampleMealPlanEntryDefinition(
            id: sampleID("5EED2000-0000-0000-0000-000000000004"),
            dateIndex: 4,
            mealType: .dinner,
            recipeID: sampleID("5EED1000-0000-0000-0000-000000000005"),
            servings: 4,
            leftoversSourceEntryID: nil
        ),
    ]

    static var sampleIngredientKeys: [String] {
        let allKeys = pantryDefinitions.map(\.nameKey) + recipeDefinitions.flatMap { definition in
            definition.ingredients.map(\.ingredientKey)
        }

        var keys: [String] = []
        var seen = Set<String>()

        for key in allKeys where seen.insert(key).inserted {
            keys.append(key)
        }

        return keys
    }

    static func seedData(
        referenceDate: Date = .now,
        localeIdentifier: String = L10n.currentSupportedLocaleIdentifier
    ) -> AppSeedData {
        let pantryItems = samplePantry(referenceDate: referenceDate, localeIdentifier: localeIdentifier)
        let recipes = sampleRecipes(localeIdentifier: localeIdentifier)

        let weekDates = WeekDateProvider.currentWeekDates(referenceDate: referenceDate)
        let mealPlanEntries = mealPlanEntryDefinitions.map { definition in
            MealPlanEntry(
                id: definition.id,
                date: weekDates[definition.dateIndex],
                mealType: definition.mealType,
                recipeID: definition.recipeID,
                servings: definition.servings,
                leftoversSourceEntryID: definition.leftoversSourceEntryID
            )
        }

        return AppSeedData(
            pantryItems: pantryItems,
            recipes: recipes,
            mealPlanEntries: mealPlanEntries,
            shoppingListItems: []
        )
    }

    static func samplePantry(
        referenceDate: Date = .now,
        localeIdentifier: String = L10n.currentSupportedLocaleIdentifier
    ) -> [PantryItem] {
        pantryDefinitions.map { definition in
            PantryItem(
                id: definition.id,
                name: localized(definition.nameKey, localeIdentifier: localeIdentifier),
                quantity: definition.quantity,
                unit: definition.unit,
                category: definition.category,
                expirationDate: definition.expirationOffsetDays.flatMap {
                    Calendar.current.date(byAdding: .day, value: $0, to: referenceDate)
                },
                isStaple: definition.isStaple
            )
        }
    }

    static func sampleRecipes(
        localeIdentifier: String = L10n.currentSupportedLocaleIdentifier
    ) -> [Recipe] {
        recipeDefinitions.map { definition in
            Recipe(
                id: definition.id,
                title: localized(definition.titleKey, localeIdentifier: localeIdentifier),
                summary: localized(definition.summaryKey, localeIdentifier: localeIdentifier),
                ingredients: definition.ingredients.map { ingredient in
                    RecipeIngredient(
                        ingredientName: localized(ingredient.ingredientKey, localeIdentifier: localeIdentifier),
                        quantity: ingredient.quantity,
                        unit: ingredient.unit
                    )
                },
                instructions: definition.instructionKeys
                    .map { localized($0, localeIdentifier: localeIdentifier) }
                    .joined(separator: "\n"),
                tags: definition.tagKeys.map { localized($0, localeIdentifier: localeIdentifier) },
                estimatedCost: definition.estimatedCost,
                prepTimeMinutes: definition.prepTimeMinutes,
                defaultServings: definition.defaultServings,
                isFavorite: definition.isFavorite
            )
        }
    }

    private static func sampleID(_ rawValue: String) -> UUID {
        guard let value = UUID(uuidString: rawValue) else {
            preconditionFailure("Invalid sample UUID: \(rawValue)")
        }

        return value
    }

    private static func localized(_ key: String, localeIdentifier: String) -> String {
        L10n.text(key, localeIdentifier: localeIdentifier)
    }
}
