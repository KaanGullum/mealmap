import Foundation

enum L10n {
    static let supportedLocaleIdentifiers = ["en", "tr"]
    static let appLanguagePreferenceKey = "appLanguagePreference"

    static var systemSupportedLocaleIdentifier: String {
        supportedLocaleIdentifier(
            Bundle.main.preferredLocalizations.first
                ?? Locale.autoupdatingCurrent.language.languageCode?.identifier
        )
    }

    static var currentSupportedLocaleIdentifier: String {
        AppLanguagePreference(rawValue: UserDefaults.standard.string(forKey: appLanguagePreferenceKey) ?? AppLanguagePreference.system.rawValue)?
            .resolvedLocaleIdentifier
            ?? systemSupportedLocaleIdentifier
    }

    static func text(_ key: String) -> String {
        text(key, localeIdentifier: currentSupportedLocaleIdentifier)
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
        String(
            format: text(key),
            locale: Locale(identifier: currentSupportedLocaleIdentifier),
            arguments: arguments
        )
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

    static func servings(_ value: Int) -> String {
        format("%d servings", Int32(value))
    }

    static func repeatCount(_ value: Int) -> String {
        format("Planned %d times", Int32(value))
    }

    static func substitutionHeader(_ ingredientName: String) -> String {
        format("Try these instead of %@", ingredientName)
    }

    static func leftoverSourceSummary(
        mealType: String,
        dateText: String,
        servings: Int
    ) -> String {
        format("%1$@ • %2$@ • %3$d servings", mealType, dateText, Int32(servings))
    }

    static func leftoverAvailableSummary(
        mealType: String,
        dateText: String,
        servings: Int
    ) -> String {
        format("%1$@ • %2$@ • %3$d servings left", mealType, dateText, Int32(servings))
    }

    static func leftoverFromEntry(
        recipeTitle: String,
        mealType: String,
        dateText: String
    ) -> String {
        format("Leftovers from %1$@ (%2$@ • %3$@)", recipeTitle, mealType, dateText)
    }

    static func budgetRemainingStatus(_ amountText: String) -> String {
        format("%@ left in this week's meal budget.", amountText)
    }

    static func budgetOverStatus(_ amountText: String) -> String {
        format("%@ over this week's meal budget.", amountText)
    }

    static func dashboardBudgetStatus(_ spentText: String, remainingText: String) -> String {
        format("You've planned %1$@ so far and still have %2$@ left.", spentText, remainingText)
    }

    static func dashboardBudgetOverStatus(_ spentText: String, overAmountText: String) -> String {
        format("You've planned %1$@ so far and are %2$@ over budget.", spentText, overAmountText)
    }

    static func budgetCapValue(_ amountText: String) -> String {
        format("Weekly cap: %@", amountText)
    }
}
