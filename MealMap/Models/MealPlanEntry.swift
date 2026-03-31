import Foundation
import SwiftData

@Model
final class MealPlanEntry: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var mealType: MealType
    var recipeID: UUID

    init(
        id: UUID = UUID(),
        date: Date,
        mealType: MealType,
        recipeID: UUID
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.mealType = mealType
        self.recipeID = recipeID
    }
}
