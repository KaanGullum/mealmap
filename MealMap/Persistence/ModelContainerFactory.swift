import SwiftData

enum ModelContainerFactory {
    static func makeSharedContainer() -> ModelContainer {
        let schema = Schema([
            PantryItem.self,
            Recipe.self,
            RecipeIngredient.self,
            MealPlanEntry.self,
            ShoppingListItem.self,
        ])

        let configuration = ModelConfiguration("SmartMealPlanner")

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create model container: \(error)")
        }
    }

    static func makePreviewContainer(seedSampleData: Bool = true) -> ModelContainer {
        let schema = Schema([
            PantryItem.self,
            Recipe.self,
            RecipeIngredient.self,
            MealPlanEntry.self,
            ShoppingListItem.self,
        ])

        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            if seedSampleData {
                let context = container.mainContext
                SampleDataFactory.seedData().insertAll(into: context)
            }
            return container
        } catch {
            fatalError("Unable to create preview container: \(error)")
        }
    }
}
