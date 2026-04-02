import SwiftData
import SwiftUI

@MainActor
struct PantryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PantryFormViewModel

    init(item: PantryItem? = nil, defaultCategory: PantryCategory? = nil) {
        _viewModel = StateObject(wrappedValue: PantryFormViewModel(item: item, defaultCategory: defaultCategory))
    }

    var body: some View {
        Form {
            Section(L10n.text("Ingredient")) {
                TextField(L10n.text("Name"), text: $viewModel.name)
                TextField(L10n.text("Quantity"), value: $viewModel.quantity, format: .number)
                    .keyboardType(.decimalPad)

                Picker(L10n.text("Unit"), selection: $viewModel.unit) {
                    ForEach(IngredientUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }

                Picker(L10n.text("Category"), selection: $viewModel.category) {
                    ForEach(PantryCategory.allCases) { category in
                        Label(category.title, systemImage: category.systemImage)
                            .tag(category)
                    }
                }
            }

            Section(L10n.text("Details")) {
                Toggle(L10n.text("Staple item"), isOn: $viewModel.isStaple)
                Toggle(L10n.text("Has expiration date"), isOn: $viewModel.expirationDateEnabled.animation())

                if viewModel.expirationDateEnabled {
                    DatePicker(
                        L10n.text("Expiration Date"),
                        selection: $viewModel.expirationDate,
                        displayedComponents: .date
                    )
                }
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(L10n.text("Cancel")) {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(L10n.text("Save")) {
                    save()
                }
                .disabled(viewModel.canSave == false)
            }
        }
    }

    private func save() {
        do {
            try viewModel.save(in: modelContext)
            dismiss()
        } catch {
            assertionFailure("Unable to save pantry item: \(error)")
        }
    }
}

struct PantryFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PantryFormView()
        }
    }
}
