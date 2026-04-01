import SwiftData

struct SampleDataLoader {
    @MainActor
    func seedIfNeeded(in context: ModelContext) async {
        let pantryDescriptor = FetchDescriptor<PantryItem>()
        let recipeDescriptor = FetchDescriptor<Recipe>()

        let pantryCount = (try? context.fetch(pantryDescriptor).count) ?? 0
        let recipeCount = (try? context.fetch(recipeDescriptor).count) ?? 0

        if pantryCount == 0, recipeCount == 0 {
            SampleDataFactory.seedData().insertAll(into: context)
        }

        SampleDataLocalizationSynchronizer().synchronize(in: context)
    }
}
