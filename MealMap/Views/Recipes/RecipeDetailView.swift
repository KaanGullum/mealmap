import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Query(sort: \PantryItem.name) private var pantryItems: [PantryItem]

    init(recipe: Recipe) {
        self.recipe = recipe
    }

    var body: some View {
        let inventory = PantryInventorySnapshot(items: pantryItems)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(recipe.title)
                        .font(.largeTitle.bold())

                    Text(recipe.summary)
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Label(recipe.estimatedCost.currencyText, systemImage: "dollarsign.circle")
                        Label("\(recipe.prepTimeMinutes) min", systemImage: "timer")
                        Label("\(recipe.ingredients.count) ingredients", systemImage: "list.bullet")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    if recipe.tags.isEmpty == false {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    TagChipView(title: tag)
                                }
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Ingredients")
                        .font(.headline)

                    ForEach(recipe.ingredients, id: \.id) { ingredient in
                        let availableQuantity = inventory.quantity(for: ingredient.ingredientName, unit: ingredient.unit)
                        let isCovered = availableQuantity >= ingredient.quantity

                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: isCovered ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isCovered ? .green : .secondary)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(ingredient.ingredientName)
                                    .font(.body.weight(.medium))
                                Text("\(ingredient.quantity.quantityText(unit: ingredient.unit)) needed")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if isCovered == false {
                                Text("Need \(max(ingredient.quantity - availableQuantity, 0).quantityText(unit: ingredient.unit))")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Instructions")
                        .font(.headline)

                    ForEach(Array(recipe.instructions.split(whereSeparator: \.isNewline).enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.subheadline.bold())
                                .foregroundStyle(.green)
                                .frame(width: 24)

                            Text(String(step))
                                .font(.body)
                        }
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RecipeDetailView(recipe: SampleDataFactory.sampleRecipes().first!)
        }
        .modelContainer(ModelContainerFactory.makePreviewContainer())
    }
}
