import Combine
import Foundation
import SwiftData

struct ShoppingListSection: Identifiable {
    let id: String
    let title: String
    let items: [ShoppingListItem]
}

@MainActor
final class ShoppingListViewModel: ObservableObject {
    private let categorizer = IngredientCategorizer()

    func sections(items: [ShoppingListItem], pantryItems: [PantryItem]) -> [ShoppingListSection] {
        let grouped = Dictionary(grouping: items) { item in
            categorizer.categoryTitle(for: item.name, pantryItems: pantryItems)
        }

        return grouped
            .map { key, value in
                ShoppingListSection(
                    id: key,
                    title: key,
                    items: value.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                )
            }
            .sorted { $0.title < $1.title }
    }

    func toggle(_ item: ShoppingListItem, in context: ModelContext) throws {
        item.isChecked.toggle()
        try context.save()
    }

    func removeCheckedItems(_ items: [ShoppingListItem], in context: ModelContext) throws {
        items.filter(\.isChecked).forEach(context.delete)
        try context.save()
    }
}
