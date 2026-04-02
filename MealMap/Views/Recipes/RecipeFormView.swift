import PhotosUI
import SwiftData
import SwiftUI

@MainActor
struct RecipeFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: RecipeFormViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var errorMessage: String?

    @MainActor
    init(recipe: Recipe? = nil) {
        _viewModel = StateObject(wrappedValue: RecipeFormViewModel(recipe: recipe))
    }

    var body: some View {
        Form {
            Section(L10n.text("Recipe Photo")) {
                VStack(spacing: 12) {
                    if let imageData = viewModel.selectedImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    } else if let imageName = viewModel.existingImageName, viewModel.imageRemoved == false {
                        RecipeImageView(imageName: imageName, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    HStack(spacing: 12) {
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Label(
                                viewModel.hasImage ? L10n.text("Change Photo") : L10n.text("Add Photo"),
                                systemImage: "photo.on.rectangle"
                            )
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .controlSize(.small)

                        if viewModel.hasImage {
                            Button(role: .destructive) {
                                viewModel.removeImage()
                                selectedPhotoItem = nil
                            } label: {
                                Label(L10n.text("Remove Photo"), systemImage: "trash")
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    do {
                        if let data = try await newItem?.loadTransferable(type: Data.self) {
                            viewModel.selectedImageData = data
                            viewModel.imageRemoved = false
                        }
                    } catch {
                        errorMessage = L10n.text("Unable to process the selected photo.")
                    }
                }
            }

            Section(L10n.text("Overview")) {
                TextField(L10n.text("Recipe title"), text: $viewModel.title)
                TextField(L10n.text("Short summary"), text: $viewModel.summary, axis: .vertical)
                    .lineLimit(2...4)
                TextField(L10n.text("Estimated cost"), value: $viewModel.estimatedCost, format: .number)
                    .keyboardType(.decimalPad)
                Stepper(value: $viewModel.prepTimeMinutes, in: 5...180, step: 5) {
                    Label(L10n.prepTime(viewModel.prepTimeMinutes), systemImage: "timer")
                }
                Stepper(value: $viewModel.defaultServings, in: 1...12) {
                    Label(L10n.servings(viewModel.defaultServings), systemImage: "person.2")
                }
                Toggle(L10n.text("Mark as favorite"), isOn: $viewModel.isFavorite)
                TextField(L10n.text("Tags (comma separated)"), text: $viewModel.tagsText)
            }

            Section(L10n.text("Ingredients")) {
                ForEach($viewModel.ingredientDrafts) { $ingredient in
                    VStack(alignment: .leading, spacing: 10) {
                        TextField(L10n.text("Ingredient name"), text: $ingredient.ingredientName)
                        HStack {
                            TextField(L10n.text("Qty"), value: $ingredient.quantity, format: .number)
                                .keyboardType(.decimalPad)

                            Picker(L10n.text("Unit"), selection: $ingredient.unit) {
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
                    Label(L10n.text("Add Ingredient"), systemImage: "plus.circle")
                }
            }

            Section(L10n.text("Instructions")) {
                TextField(L10n.text("Add one step per line"), text: $viewModel.instructions, axis: .vertical)
                    .lineLimit(6...10)
            }
        }
        .navigationTitle(viewModel.formTitle)
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
        .alert(L10n.text("Error"), isPresented: Binding(
            get: { errorMessage != nil },
            set: { if $0 == false { errorMessage = nil } }
        ), actions: {
            Button(L10n.text("OK")) { errorMessage = nil }
        }, message: {
            Text(errorMessage ?? "")
        })
    }

    private func save() {
        do {
            try viewModel.save(in: modelContext)
            dismiss()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? L10n.text("Unable to save the recipe right now.")
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
