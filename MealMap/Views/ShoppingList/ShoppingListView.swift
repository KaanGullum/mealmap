import SwiftData
import SwiftUI

struct ShoppingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShoppingListItem.name) private var shoppingListItems: [ShoppingListItem]
    @Query(sort: \PantryItem.name) private var pantryItems: [PantryItem]
    @StateObject private var viewModel = ShoppingListViewModel()

    init() {}

    var body: some View {
        List {
            if shoppingListItems.isEmpty {
                Section {
                    EmptyStateView(
                        title: L10n.text("Shopping list is empty"),
                        message: L10n.text("Generate a list from the weekly planner and only missing ingredients will appear here."),
                        systemImage: "cart"
                    )
                }
            } else {
                Section {
                    HStack {
                        SummaryMetricCard(
                            title: L10n.text("Items"),
                            value: "\(shoppingListItems.count)",
                            systemImage: "cart"
                        )
                        SummaryMetricCard(
                            title: L10n.text("Checked"),
                            value: "\(shoppingListItems.filter(\.isChecked).count)",
                            systemImage: "checkmark.circle"
                        )
                    }
                }

                ForEach(sections) { section in
                    Section(section.title) {
                        ForEach(section.items, id: \.id) { item in
                            Button {
                                viewModel.toggle(item, in: modelContext)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(item.isChecked ? .green : .secondary)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .foregroundStyle(.primary)
                                            .strikethrough(item.isChecked)
                                        Text(item.quantity.quantityText(unit: item.unit))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Shopping List")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Remove Checked") {
                    viewModel.removeCheckedItems(shoppingListItems, in: modelContext)
                }
                .disabled(shoppingListItems.contains(where: \.isChecked) == false)
            }
        }
    }

    private var sections: [ShoppingListSection] {
        viewModel.sections(items: shoppingListItems, pantryItems: pantryItems)
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ShoppingListView()
        }
        .modelContainer(ModelContainerFactory.makePreviewContainer())
    }
}
