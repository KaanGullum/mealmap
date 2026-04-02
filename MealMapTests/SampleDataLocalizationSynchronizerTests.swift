import SwiftData
import XCTest
@testable import MealMap

@MainActor
final class SampleDataLocalizationSynchronizerTests: XCTestCase {
    func testSynchronizerBackfillsSampleRecipeImageNames() throws {
        let container = ModelContainerFactory.makePreviewContainer()
        let context = container.mainContext
        let recipes = try context.fetch(FetchDescriptor<Recipe>())

        let definition = try XCTUnwrap(SampleDataFactory.recipeDefinitions.first)
        let recipe = try XCTUnwrap(recipes.first(where: { $0.id == definition.id }))
        recipe.imageName = nil
        try context.save()

        SampleDataLocalizationSynchronizer(localeIdentifier: "en").synchronize(in: context)

        XCTAssertEqual(recipe.imageName, definition.imageName)
    }
}
