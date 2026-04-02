import SwiftData
import SwiftUI

@MainActor
struct PantryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PantryItem.name) private var pantryItems: [PantryItem]
    @StateObject private var viewModel: PantryViewModel
    @State private var showAddForm = false
    @State private var editingItem: PantryItem?
    @State private var errorMessage: String?
    @AppStorage("lastUsedPantryCategory") private var lastUsedPantryCategoryRawValue = PantryCategory.produce.rawValue

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: PantryViewModel())
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    categoryFilter

                    if filteredItems.isEmpty {
                        EmptyStateView(
                            title: L10n.text("Your pantry is empty"),
                            message: L10n.text("Add a few ingredients to unlock recipe matching and shopping list generation."),
                            systemImage: "cabinet",
                            buttonTitle: L10n.text("Add Item")
                        ) {
                            showAddForm = true
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }

            if filteredItems.isEmpty == false {
                Section(L10n.text("Items")) {
                    ForEach(filteredItems, id: \.id) { item in
                        PantryItemRow(item: item)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(L10n.text("Delete"), role: .destructive) {
                                    delete(item)
                                }
                                Button(L10n.text("Edit")) {
                                    editingItem = item
                                }
                                .tint(.blue)
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(L10n.text("Pantry"))
        .searchable(text: $viewModel.searchText, prompt: L10n.text("Search ingredients"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddForm = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddForm) {
            NavigationStack {
                PantryFormView(defaultCategory: defaultCategoryForNewItem)
            }
        }
        .sheet(item: $editingItem) { item in
            NavigationStack {
                PantryFormView(item: item)
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

    private var filteredItems: [PantryItem] {
        viewModel.filteredItems(from: pantryItems)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(
                    title: L10n.text("All"),
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectedCategory = nil
                }

                ForEach(PantryCategory.allCases) { category in
                    FilterChip(
                        title: category.title,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
        }
    }

    private var defaultCategoryForNewItem: PantryCategory {
        if let selectedCategory = viewModel.selectedCategory {
            return selectedCategory
        }

        return PantryCategory(rawValue: lastUsedPantryCategoryRawValue) ?? .produce
    }

    private func delete(_ item: PantryItem) {
        do {
            modelContext.delete(item)
            try modelContext.save()
        } catch {
            errorMessage = L10n.text("Unable to delete the pantry item right now.")
        }
    }
}

private struct PantryItemRow: View {
    let item: PantryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.systemImage)
                .font(.title3)
                .foregroundStyle(.green)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                    if item.isStaple {
                        TagChipView(title: L10n.text("Staple"))
                    }
                }

                Text("\(item.quantity.quantityText(unit: item.unit)) • \(item.category.title)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let expirationDate = item.expirationDate {
                    Label(L10n.expires(expirationDate.dayMonthText), systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(expirationDate.isWithinUpcoming(days: 3) ? .orange : .secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    isSelected ? Color.green : Color.secondary.opacity(0.12),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }
}

struct PantryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PantryView()
        }
        .modelContainer(ModelContainerFactory.makePreviewContainer())
    }
}
