import Combine
import Foundation
import SwiftData

@MainActor
final class PantryFormViewModel: ObservableObject {
    private enum Defaults {
        static let lastUsedCategoryKey = "lastUsedPantryCategory"
    }

    @Published var name: String
    @Published var quantity: Double
    @Published var unit: IngredientUnit
    @Published var category: PantryCategory
    @Published var expirationDateEnabled: Bool
    @Published var expirationDate: Date
    @Published var isStaple: Bool

    private let existingItem: PantryItem?

    init(item: PantryItem? = nil, defaultCategory: PantryCategory? = nil) {
        self.existingItem = item
        self.name = item?.name ?? ""
        self.quantity = item?.quantity ?? 1
        self.unit = item?.unit ?? .piece
        self.category = item?.category ?? defaultCategory ?? Self.lastUsedCategory
        self.expirationDate = item?.expirationDate ?? .now
        self.expirationDateEnabled = item?.expirationDate != nil
        self.isStaple = item?.isStaple ?? false
    }

    var title: String {
        existingItem == nil ? L10n.text("Add Pantry Item") : L10n.text("Edit Pantry Item")
    }

    var canSave: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && quantity > 0
    }

    func save(in context: ModelContext) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalExpirationDate = expirationDateEnabled ? expirationDate : nil

        if let existingItem {
            existingItem.name = trimmedName
            existingItem.quantity = quantity
            existingItem.unit = unit
            existingItem.category = category
            existingItem.expirationDate = finalExpirationDate
            existingItem.isStaple = isStaple
        } else {
            let newItem = PantryItem(
                name: trimmedName,
                quantity: quantity,
                unit: unit,
                category: category,
                expirationDate: finalExpirationDate,
                isStaple: isStaple
            )
            context.insert(newItem)
        }

        Self.lastUsedCategory = category
        try context.save()
    }

    private static var lastUsedCategory: PantryCategory {
        get {
            guard
                let rawValue = UserDefaults.standard.string(forKey: Defaults.lastUsedCategoryKey),
                let category = PantryCategory(rawValue: rawValue)
            else {
                return .produce
            }

            return category
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Defaults.lastUsedCategoryKey)
        }
    }
}
