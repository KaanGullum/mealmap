import Foundation

enum L10n {
    static let supportedLocaleIdentifiers = ["en", "tr"]

    static var currentSupportedLocaleIdentifier: String {
        supportedLocaleIdentifier(
            Bundle.main.preferredLocalizations.first
                ?? Locale.autoupdatingCurrent.language.languageCode?.identifier
        )
    }

    static func text(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    static func text(_ key: String, localeIdentifier: String) -> String {
        let resolvedLocaleIdentifier = supportedLocaleIdentifier(localeIdentifier)

        if resolvedLocaleIdentifier == "en" {
            return key
        }

        guard
            let path = Bundle.main.path(forResource: resolvedLocaleIdentifier, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return key
        }

        return bundle.localizedString(forKey: key, value: key, table: nil)
    }

    static func variants(for key: String, locales: [String] = supportedLocaleIdentifiers) -> Set<String> {
        Set(locales.map { text(key, localeIdentifier: $0) })
    }

    static func supportedLocaleIdentifier(_ rawLocaleIdentifier: String?) -> String {
        guard let rawLocaleIdentifier else {
            return "en"
        }

        let normalized = rawLocaleIdentifier
            .replacingOccurrences(of: "_", with: "-")
            .lowercased()

        if normalized.hasPrefix("tr") {
            return "tr"
        }

        return "en"
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: .autoupdatingCurrent, arguments: arguments)
    }

    static func readyIngredients(matched: Int, total: Int) -> String {
        format("%1$d/%2$d ingredients ready", Int32(matched), Int32(total))
    }

    static func expires(_ dateText: String) -> String {
        format("Expires %@", dateText)
    }

    static func minutes(_ value: Int) -> String {
        format("%d min", Int32(value))
    }

    static func prepTime(_ value: Int) -> String {
        format("%d min prep time", Int32(value))
    }

    static func ingredientCount(_ value: Int) -> String {
        format("%d ingredients", Int32(value))
    }

    static func quantityNeeded(_ quantityText: String) -> String {
        format("%@ needed", quantityText)
    }

    static func needQuantity(_ quantityText: String) -> String {
        format("Need %@", quantityText)
    }

    static func durationAndCost(minutes: Int, costText: String) -> String {
        format("%1$d min • %2$@", Int32(minutes), costText)
    }

    static func mealTypeAndDate(_ mealType: String, dateText: String) -> String {
        format("%1$@ • %2$@", mealType, dateText)
    }

    static func addedMissingItems(_ count: Int) -> String {
        format("%d missing items were added to the shopping list.", Int32(count))
    }
}
