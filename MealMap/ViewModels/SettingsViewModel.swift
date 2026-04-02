import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    var localModeDescription: String {
        L10n.text("This starter app runs entirely on-device with SwiftData and rule-based recommendations.")
    }
}
