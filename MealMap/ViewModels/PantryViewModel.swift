import Combine
import Foundation

@MainActor
final class PantryViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: PantryCategory?

    func filteredItems(from items: [PantryItem]) -> [PantryItem] {
        items
            .filter { item in
                let matchesSearch = searchText.isEmpty
                    || item.name.localizedCaseInsensitiveContains(searchText)
                let matchesCategory = selectedCategory == nil || item.category == selectedCategory
                return matchesSearch && matchesCategory
            }
            .sorted {
                if $0.category == $1.category {
                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
                return $0.category.title < $1.category.title
            }
    }
}
