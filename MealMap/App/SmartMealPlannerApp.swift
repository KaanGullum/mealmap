import SwiftData
import SwiftUI

@main
struct MealMapApp: App {
    private let sharedModelContainer = ModelContainerFactory.makeSharedContainer()

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
