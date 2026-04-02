import SwiftData
import SwiftUI

@MainActor
struct ShoppingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShoppingListItem.name) private var shoppingListItems: [ShoppingListItem]
    @Query(sort: \PantryItem.name) private var pantryItems: [PantryItem]
    @StateObject private var viewModel: ShoppingListViewModel
    @State private var errorMessage: String?

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: ShoppingListViewModel())
    }

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
                                toggle(item)
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
        .navigationTitle(L10n.text("Shopping List"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L10n.text("Remove Checked")) {
                    removeChecked()
                }
                .disabled(shoppingListItems.contains(where: \.isChecked) == false)
            }
        }
        .alert(L10n.text("Error"), isPresented: Binding(
            get: { errorMessage != nil },
            set: { if $0 == false { errorMessage = nil } }
        ), actions: {
            Button(L10n.text("OK")) { errorMessage = nil }
        }, message: {
            Text(errorMessage ?? "")
        })
    }

    private var sections: [ShoppingListSection] {
        viewModel.sections(items: shoppingListItems, pantryItems: pantryItems)
    }

    private func toggle(_ item: ShoppingListItem) {
        do {
            try viewModel.toggle(item, in: modelContext)
        } catch {
            errorMessage = L10n.text("Unable to update the item right now.")
        }
    }

    private func removeChecked() {
        do {
            try viewModel.removeCheckedItems(shoppingListItems, in: modelContext)
        } catch {
            errorMessage = L10n.text("Unable to remove checked items right now.")
        }
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
