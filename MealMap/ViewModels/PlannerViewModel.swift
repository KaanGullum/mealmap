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

    init(shoppingListGenerator: ShoppingListGenerating) {
        self.shoppingListGenerator = shoppingListGenerator
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
        in context: ModelContext
    ) throws {
        if let existingEntry = entry(for: date, mealType: mealType, entries: existingEntries) {
            existingEntry.recipeID = recipe.id
        } else {
            context.insert(MealPlanEntry(date: date, mealType: mealType, recipeID: recipe.id))
        }

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
        let recipeByID = Dictionary(uniqueKeysWithValues: recipes.map { ($0.id, $0) })
        return entries.reduce(0) { partialResult, entry in
            partialResult + (recipeByID[entry.recipeID]?.estimatedCost ?? 0)
        }
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
