import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    let roadmapItems = [
        "API connector placeholder for future AI meal recommendations",
        "Budget profiles for tighter weekly cost controls",
        "Household sharing and cloud sync",
        "Pantry barcode scanning and receipt OCR",
    ]

    let localModeDescription = "This starter app runs entirely on-device with SwiftData and rule-based recommendations."
}
