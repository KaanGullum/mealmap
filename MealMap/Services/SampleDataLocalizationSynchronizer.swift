import SwiftData

struct SampleDataLocalizationSynchronizer {
    private let localeIdentifier: String
    private let localizedIngredientNameByVariant: [String: String]

    init(localeIdentifier: String = L10n.currentSupportedLocaleIdentifier) {
        self.localeIdentifier = localeIdentifier

        var mapping: [String: String] = [:]
        for ingredientKey in SampleDataFactory.sampleIngredientKeys {
            let localizedName = L10n.text(ingredientKey, localeIdentifier: localeIdentifier)
            for variant in L10n.variants(for: ingredientKey) {
                mapping[variant.normalizedIngredientName] = localizedName
            }
        }

        self.localizedIngredientNameByVariant = mapping
    }

    @MainActor
    func synchronize(in context: ModelContext) {
        let pantryItems = (try? context.fetch(FetchDescriptor<PantryItem>())) ?? []
        let recipes = (try? context.fetch(FetchDescriptor<Recipe>())) ?? []
        let shoppingListItems = (try? context.fetch(FetchDescriptor<ShoppingListItem>())) ?? []

        var didChange = false
        didChange = synchronizePantryItems(pantryItems) || didChange
        didChange = synchronizeRecipes(recipes) || didChange
        didChange = synchronizeShoppingListItems(shoppingListItems) || didChange

        guard didChange else {
            return
        }

        try? context.save()
    }

    private func synchronizePantryItems(_ pantryItems: [PantryItem]) -> Bool {
        var didChange = false

        for pantryItem in pantryItems {
            guard let localizedName = localizedIngredientName(for: pantryItem.name),
                  pantryItem.name != localizedName else {
                continue
            }

            pantryItem.name = localizedName
            didChange = true
        }

        return didChange
    }

    private func synchronizeRecipes(_ recipes: [Recipe]) -> Bool {
        var didChange = false

        for recipe in recipes {
            guard let definition = sampleDefinition(for: recipe) else {
                continue
            }

            let localizedTitle = localized(definition.titleKey)
            if recipe.title != localizedTitle {
                recipe.title = localizedTitle
                didChange = true
            }

            let localizedSummary = localized(definition.summaryKey)
            if recipe.summary != localizedSummary {
                recipe.summary = localizedSummary
                didChange = true
            }

            let localizedInstructions = definition.instructionKeys
                .map(localized)
                .joined(separator: "\n")
            if recipe.instructions != localizedInstructions {
                recipe.instructions = localizedInstructions
                didChange = true
            }

            let localizedTags = definition.tagKeys.map(localized)
            if recipe.tags != localizedTags {
                recipe.tags = localizedTags
                didChange = true
            }

            if recipe.defaultServings != definition.defaultServings {
                recipe.defaultServings = definition.defaultServings
                didChange = true
            }

            if recipe.imageName != definition.imageName {
                recipe.imageName = definition.imageName
                didChange = true
            }

            didChange = synchronizeRecipeIngredients(recipe.ingredients, definition: definition) || didChange
        }

        return didChange
    }

    private func synchronizeRecipeIngredients(
        _ ingredients: [RecipeIngredient],
        definition: SampleRecipeDefinition
    ) -> Bool {
        var didChange = false
        let localizedIngredientMapping = localizedIngredientMapping(for: definition)

        for ingredient in ingredients {
            guard let localizedName = localizedIngredientMapping[ingredient.ingredientName.normalizedIngredientName],
                  ingredient.ingredientName != localizedName else {
                continue
            }

            ingredient.ingredientName = localizedName
            didChange = true
        }

        return didChange
    }

    private func synchronizeShoppingListItems(_ shoppingListItems: [ShoppingListItem]) -> Bool {
        var didChange = false

        for shoppingListItem in shoppingListItems {
            guard let localizedName = localizedIngredientName(for: shoppingListItem.name),
                  shoppingListItem.name != localizedName else {
                continue
            }

            shoppingListItem.name = localizedName
            didChange = true
        }

        return didChange
    }

    private func sampleDefinition(for recipe: Recipe) -> SampleRecipeDefinition? {
        SampleDataFactory.recipeDefinitions.first { definition in
            if recipe.id == definition.id {
                return true
            }

            let normalizedTitle = recipe.title.normalizedIngredientName
            let titleVariants = Set(L10n.variants(for: definition.titleKey).map(\.normalizedIngredientName))
            if titleVariants.contains(normalizedTitle) {
                return true
            }

            let normalizedSummary = recipe.summary.normalizedIngredientName
            let summaryVariants = Set(L10n.variants(for: definition.summaryKey).map(\.normalizedIngredientName))
            let costMatches = abs(recipe.estimatedCost - definition.estimatedCost) < 0.001

            return summaryVariants.contains(normalizedSummary)
                && recipe.prepTimeMinutes == definition.prepTimeMinutes
                && costMatches
        }
    }

    private func localizedIngredientMapping(for definition: SampleRecipeDefinition) -> [String: String] {
        var mapping: [String: String] = [:]

        for ingredient in definition.ingredients {
            let localizedName = localized(ingredient.ingredientKey)
            for variant in L10n.variants(for: ingredient.ingredientKey) {
                mapping[variant.normalizedIngredientName] = localizedName
            }
        }

        return mapping
    }

    private func localizedIngredientName(for currentName: String) -> String? {
        localizedIngredientNameByVariant[currentName.normalizedIngredientName]
    }

    private func localized(_ key: String) -> String {
        L10n.text(key, localeIdentifier: localeIdentifier)
    }
}
