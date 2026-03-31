import SwiftUI

struct PantryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PantryFormViewModel

    init(item: PantryItem? = nil) {
        _viewModel = StateObject(wrappedValue: PantryFormViewModel(item: item))
    }

    var body: some View {
        Form {
            Section("Ingredient") {
                TextField("Name", text: $viewModel.name)
                TextField("Quantity", value: $viewModel.quantity, format: .number)
                    .keyboardType(.decimalPad)

                Picker("Unit", selection: $viewModel.unit) {
                    ForEach(IngredientUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }

                Picker("Category", selection: $viewModel.category) {
                    ForEach(PantryCategory.allCases) { category in
                        Label(category.title, systemImage: category.systemImage)
                            .tag(category)
                    }
                }
            }

            Section("Details") {
                Toggle("Staple item", isOn: $viewModel.isStaple)
                Toggle("Has expiration date", isOn: $viewModel.expirationDateEnabled.animation())

                if viewModel.expirationDateEnabled {
                    DatePicker(
                        "Expiration Date",
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
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
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
