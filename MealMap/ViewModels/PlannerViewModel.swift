import Combine
import Foundation
import SwiftData

struct PlannerSelectionContext: Identifiable {
    let date: Date
    let mealType: MealType

    var id: String {
        "\(date.timeIntervalSince1970)-\(mealType.rawValue)"
    }
}

@MainActor
final class PlannerViewModel: ObservableObject {
    private let shoppingListGenerator: ShoppingListGenerating
    private let metricsService: MealPlanMetricsService

    init(
        shoppingListGenerator: ShoppingListGenerating,
        metricsService: MealPlanMetricsService = MealPlanMetricsService()
    ) {
        self.shoppingListGenerator = shoppingListGenerator
        self.metricsService = metricsService
    }

    convenience init() {
        self.init(shoppingListGenerator: ShoppingListGenerator())
    }

    var weekDates: [Date] {
        WeekDateProvider.currentWeekDates()
    }

    func recipe(for entry: MealPlanEntry?, recipes: [Recipe]) -> Recipe? {
        guard let entry else {
            return nil
        }

        return recipes.first(where: { $0.id == entry.recipeID })
    }

    func entry(
        for date: Date,
        mealType: MealType,
        entries: [MealPlanEntry]
    ) -> MealPlanEntry? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return entries.first { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: startOfDay) && entry.mealType == mealType
        }
    }

    func assign(
        recipe: Recipe,
        for date: Date,
        mealType: MealType,
        existingEntries: [MealPlanEntry],
        servings: Int? = nil,
        in context: ModelContext
    ) throws {
        let plannedServings = max(servings ?? recipe.defaultServings, 1)

        if let existingEntry = entry(for: date, mealType: mealType, entries: existingEntries) {
            existingEntry.recipeID = recipe.id
            existingEntry.servings = plannedServings
            existingEntry.leftoversSourceEntryID = nil
        } else {
            context.insert(
                MealPlanEntry(
                    date: date,
                    mealType: mealType,
                    recipeID: recipe.id,
                    servings: plannedServings
                )
            )
        }

        try context.save()
    }

    func assignLeftovers(
        from sourceEntry: MealPlanEntry,
        for date: Date,
        mealType: MealType,
        recipes: [Recipe],
        existingEntries: [MealPlanEntry],
        in context: ModelContext
    ) throws {
        let existingEntry = entry(for: date, mealType: mealType, entries: existingEntries)
        let entriesExcludingCurrent = existingEntries.filter { $0.id != existingEntry?.id }
        let recipe = recipes.first(where: { $0.id == sourceEntry.recipeID })
        let remainingServings = metricsService.remainingLeftoverServings(
            for: sourceEntry,
            entries: entriesExcludingCurrent
        )
        let defaultLeftoverServings = max(1, sourceEntry.servings / 2)
        let cappedByRecipe = min(defaultLeftoverServings, recipe?.defaultServings ?? defaultLeftoverServings)
        let plannedServings = max(1, min(cappedByRecipe, remainingServings))

        if let existingEntry {
            existingEntry.recipeID = sourceEntry.recipeID
            existingEntry.servings = plannedServings
            existingEntry.leftoversSourceEntryID = sourceEntry.id
        } else {
            context.insert(
                MealPlanEntry(
                    date: date,
                    mealType: mealType,
                    recipeID: sourceEntry.recipeID,
                    servings: plannedServings,
                    leftoversSourceEntryID: sourceEntry.id
                )
            )
        }

        try context.save()
    }

    func updateServings(
        for entry: MealPlanEntry,
        servings: Int,
        in context: ModelContext
    ) throws {
        entry.servings = max(servings, 1)
        try context.save()
    }

    func clearMeal(
        for date: Date,
        mealType: MealType,
        existingEntries: [MealPlanEntry],
        in context: ModelContext
    ) throws {
        guard let existingEntry = entry(for: date, mealType: mealType, entries: existingEntries) else {
            return
        }

        context.delete(existingEntry)
        try context.save()
    }

    func weeklyEstimatedCost(entries: [MealPlanEntry], recipes: [Recipe]) -> Double {
        metricsService.weeklyEstimatedCost(entries: entries, recipes: recipes)
    }

    func remainingBudget(
        budgetLimit: Double,
        entries: [MealPlanEntry],
        recipes: [Recipe]
    ) -> Double {
        metricsService.remainingBudget(
            budgetLimit: budgetLimit,
            entries: entries,
            recipes: recipes
        )
    }

    func plannedCost(for entry: MealPlanEntry, recipe: Recipe?) -> Double {
        guard
            let recipe,
            metricsService.isFreshCookEntry(entry)
        else {
            return 0
        }

        return recipe.estimatedCost * metricsService.ingredientMultiplier(for: entry, recipe: recipe)
    }

    func isLeftoverEntry(_ entry: MealPlanEntry) -> Bool {
        metricsService.isFreshCookEntry(entry) == false
    }

    func servings(for entry: MealPlanEntry, recipe: Recipe?) -> Int {
        guard let recipe else {
            return max(entry.servings, 1)
        }

        return metricsService.servings(for: entry, recipe: recipe)
    }

    func leftoverSource(
        for entry: MealPlanEntry,
        entries: [MealPlanEntry]
    ) -> MealPlanEntry? {
        guard let leftoversSourceEntryID = entry.leftoversSourceEntryID else {
            return nil
        }

        return entries.first(where: { $0.id == leftoversSourceEntryID })
    }

    func leftoverCandidates(
        for date: Date,
        entries: [MealPlanEntry]
    ) -> [MealPlanEntry] {
        metricsService.eligibleLeftoverSources(for: date, entries: entries)
    }

    func remainingLeftoverServings(
        for sourceEntry: MealPlanEntry,
        entries: [MealPlanEntry]
    ) -> Int {
        metricsService.remainingLeftoverServings(for: sourceEntry, entries: entries)
    }

    func generateShoppingList(
        pantryItems: [PantryItem],
        plannedEntries: [MealPlanEntry],
        recipes: [Recipe],
        existingItems: [ShoppingListItem],
        in context: ModelContext
    ) throws -> Int {
        existingItems.forEach(context.delete)

        let generatedItems = shoppingListGenerator.generate(
            pantryItems: pantryItems,
            plannedEntries: plannedEntries,
            recipes: recipes
        )

        for item in generatedItems {
            context.insert(
                ShoppingListItem(
                    name: item.name,
                    quantity: item.quantity,
                    unit: item.unit
                )
            )
        }

        try context.save()
        return generatedItems.count
    }
}
