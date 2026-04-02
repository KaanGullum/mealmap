import SwiftData
import SwiftUI

@MainActor
struct RecipeFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: RecipeFormViewModel

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: RecipeFormViewModel())
    }

    var body: some View {
        Form {
            Section("Overview") {
                TextField("Recipe title", text: $viewModel.title)
                TextField("Short summary", text: $viewModel.summary, axis: .vertical)
                    .lineLimit(2...4)
                TextField("Estimated cost", value: $viewModel.estimatedCost, format: .number)
                    .keyboardType(.decimalPad)
                Stepper(value: $viewModel.prepTimeMinutes, in: 5...180, step: 5) {
                    Label(L10n.prepTime(viewModel.prepTimeMinutes), systemImage: "timer")
                }
                Stepper(value: $viewModel.defaultServings, in: 1...12) {
                    Label(L10n.servings(viewModel.defaultServings), systemImage: "person.2")
                }
                Toggle("Mark as favorite", isOn: $viewModel.isFavorite)
                TextField("Tags (comma separated)", text: $viewModel.tagsText)
            }

            Section("Ingredients") {
                ForEach($viewModel.ingredientDrafts) { $ingredient in
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Ingredient name", text: $ingredient.ingredientName)
                        HStack {
                            TextField("Qty", value: $ingredient.quantity, format: .number)
                                .keyboardType(.decimalPad)

                            Picker("Unit", selection: $ingredient.unit) {
                                ForEach(IngredientUnit.allCases) { unit in
                                    Text(unit.displayName).tag(unit)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: viewModel.removeIngredientDraft)

                Button {
                    viewModel.addIngredientDraft()
                } label: {
                    Label("Add Ingredient", systemImage: "plus.circle")
                }
            }

            Section("Instructions") {
                TextField("Add one step per line", text: $viewModel.instructions, axis: .vertical)
                    .lineLimit(6...10)
            }
        }
        .navigationTitle("Add Recipe")
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
            assertionFailure("Unable to save recipe: \(error)")
        }
    }
}

struct RecipeFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RecipeFormView()
        }
    }
}
