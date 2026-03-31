import SwiftUI

struct MealPlanPickerView: View {
    let date: Date
    let mealType: MealType
    let recipes: [Recipe]
    let selectedRecipeID: UUID?
    let onSelect: (Recipe) -> Void
    let onClear: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if selectedRecipeID != nil {
                    Section {
                        Button(role: .destructive) {
                            onClear()
                            dismiss()
                        } label: {
                            Label("Clear Selection", systemImage: "trash")
                        }
                    }
                }

                Section("Recipes") {
                    ForEach(recipes, id: \.id) { recipe in
                        Button {
                            onSelect(recipe)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recipe.title)
                                        .foregroundStyle(.primary)
                                    Text("\(recipe.prepTimeMinutes) min • \(recipe.estimatedCost.currencyText)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if selectedRecipeID == recipe.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("\(mealType.title) • \(date.formatted(.dateTime.month().day()))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MealPlanPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MealPlanPickerView(
            date: .now,
            mealType: .dinner,
            recipes: SampleDataFactory.sampleRecipes(),
            selectedRecipeID: nil,
            onSelect: { _ in },
            onClear: {}
        )
    }
}
