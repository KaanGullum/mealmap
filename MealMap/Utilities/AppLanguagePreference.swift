import Foundation

enum AppLanguagePreference: String, CaseIterable, Identifiable {
    case system
    case english
    case turkish

    var id: String { rawValue }

    var resolvedLocaleIdentifier: String {
        switch self {
        case .system:
            L10n.systemSupportedLocaleIdentifier
        case .english:
            "en"
        case .turkish:
            "tr"
        }
    }

    var locale: Locale {
        switch self {
        case .system:
            .autoupdatingCurrent
        case .english:
            Locale(identifier: "en")
        case .turkish:
            Locale(identifier: "tr")
        }
    }

    var titleKey: String {
        switch self {
        case .system:
            "Follow System"
        case .english:
            "English"
        case .turkish:
            "Turkish"
        }
    }
}
