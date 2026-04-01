import Foundation

extension Double {
    func quantityText(unit: IngredientUnit) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.maximumFractionDigits = self == floor(self) ? 0 : 1
        formatter.minimumFractionDigits = 0
        let value = formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        return "\(value) \(unit.displayName)"
    }

    var currencyText: String {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
}
