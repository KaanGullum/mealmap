import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    var roadmapItems: [String] {
        [
            L10n.text("API connector placeholder for future AI meal recommendations"),
            L10n.text("Budget profiles for tighter weekly cost controls"),
            L10n.text("Household sharing and cloud sync"),
            L10n.text("Pantry barcode scanning and receipt OCR"),
        ]
    }

    var localModeDescription: String {
        L10n.text("This starter app runs entirely on-device with SwiftData and rule-based recommendations.")
    }
}
