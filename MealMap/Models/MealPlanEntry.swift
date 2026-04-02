import Foundation
import SwiftData

@Model
final class MealPlanEntry: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var mealType: MealType
    var recipeID: UUID
    var servings: Int = 2
    var leftoversSourceEntryID: UUID?

    init(
        id: UUID = UUID(),
        date: Date,
        mealType: MealType,
        recipeID: UUID,
        servings: Int = 2,
        leftoversSourceEntryID: UUID? = nil
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.mealType = mealType
        self.recipeID = recipeID
        self.servings = servings
        self.leftoversSourceEntryID = leftoversSourceEntryID
    }
}
