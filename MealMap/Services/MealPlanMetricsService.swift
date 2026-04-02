import Foundation

struct MealPlanMetricsService {
    func ingredientMultiplier(for entry: MealPlanEntry, recipe: Recipe) -> Double {
        Double(servings(for: entry, recipe: recipe)) / Double(max(recipe.defaultServings, 1))
    }

    func servings(for entry: MealPlanEntry, recipe: Recipe) -> Int {
        max(entry.servings, 1)
    }

    func isFreshCookEntry(_ entry: MealPlanEntry) -> Bool {
        entry.leftoversSourceEntryID == nil
    }

    func weeklyEstimatedCost(entries: [MealPlanEntry], recipes: [Recipe]) -> Double {
        let recipeByID = Dictionary(uniqueKeysWithValues: recipes.map { ($0.id, $0) })

        return entries.reduce(0) { partialResult, entry in
            guard
                isFreshCookEntry(entry),
                let recipe = recipeByID[entry.recipeID]
            else {
                return partialResult
            }

            return partialResult + (recipe.estimatedCost * ingredientMultiplier(for: entry, recipe: recipe))
        }
    }

    func remainingBudget(
        budgetLimit: Double,
        entries: [MealPlanEntry],
        recipes: [Recipe]
    ) -> Double {
        budgetLimit - weeklyEstimatedCost(entries: entries, recipes: recipes)
    }

    func recipeUsageCounts(entries: [MealPlanEntry]) -> [UUID: Int] {
        entries.reduce(into: [:]) { partialResult, entry in
            partialResult[entry.recipeID, default: 0] += 1
        }
    }

    func remainingLeftoverServings(
        for sourceEntry: MealPlanEntry,
        entries: [MealPlanEntry]
    ) -> Int {
        guard isFreshCookEntry(sourceEntry) else {
            return 0
        }

        let usedServings = entries
            .filter { $0.leftoversSourceEntryID == sourceEntry.id }
            .reduce(0) { $0 + max($1.servings, 1) }

        return max(sourceEntry.servings - usedServings, 0)
    }

    func eligibleLeftoverSources(
        for targetDate: Date,
        entries: [MealPlanEntry]
    ) -> [MealPlanEntry] {
        let calendar = Calendar.current
        let startOfTargetDay = calendar.startOfDay(for: targetDate)

        return entries
            .filter { entry in
                entry.leftoversSourceEntryID == nil
                    && calendar.startOfDay(for: entry.date) < startOfTargetDay
                    && remainingLeftoverServings(for: entry, entries: entries) > 0
            }
            .sorted {
                if $0.date == $1.date {
                    return $0.mealType.rawValue < $1.mealType.rawValue
                }
                return $0.date > $1.date
            }
    }
}
