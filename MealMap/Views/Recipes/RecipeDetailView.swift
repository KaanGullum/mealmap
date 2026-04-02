import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let recipe: Recipe
    @Query(sort: \PantryItem.name) private var pantryItems: [PantryItem]
    @Query(sort: \MealPlanEntry.date) private var mealPlanEntries: [MealPlanEntry]
    private let substitutionService = IngredientSubstitutionService()

    init(recipe: Recipe) {
        self.recipe = recipe
    }

    var body: some View {
        let inventory = PantryInventorySnapshot(items: pantryItems)
        let missingIngredients = recipe.ingredients.filter { ingredient in
            inventory.quantity(for: ingredient.ingredientName, unit: ingredient.unit) + 0.01 < ingredient.quantity
        }
        let substitutionGuidance = substitutionService.guidance(
            for: missingIngredients,
            pantryItems: pantryItems
        )
        let plannedCount = mealPlanEntries.filter { $0.recipeID == recipe.id }.count

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text(recipe.title)
                            .font(.largeTitle.bold())

                        Spacer()

                        if recipe.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.title3)
                                .foregroundStyle(.yellow)
                        }
                    }

                    Text(recipe.summary)
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Label(recipe.estimatedCost.currencyText, systemImage: MealMapSymbols.cost)
                        Label(L10n.minutes(recipe.prepTimeMinutes), systemImage: "timer")
                        Label(L10n.servings(recipe.defaultServings), systemImage: "person.2")
                        Label(L10n.ingredientCount(recipe.ingredients.count), systemImage: "list.bullet")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    if plannedCount > 0 {
                        TagChipView(title: L10n.repeatCount(plannedCount))
                    }

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
                                Text(L10n.quantityNeeded(ingredient.quantity.quantityText(unit: ingredient.unit)))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if isCovered == false {
                                Text(L10n.needQuantity(max(ingredient.quantity - availableQuantity, 0).quantityText(unit: ingredient.unit)))
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }

                if substitutionGuidance.isEmpty == false {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Smart swaps")
                            .font(.headline)

                        ForEach(substitutionGuidance) { guidance in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(L10n.substitutionHeader(guidance.ingredientName))
                                    .font(.subheadline.weight(.semibold))

                                ForEach(guidance.suggestions) { suggestion in
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: suggestion.isPantryAvailable ? "checkmark.seal.fill" : "arrow.triangle.2.circlepath")
                                            .foregroundStyle(suggestion.isPantryAvailable ? .green : .orange)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(suggestion.substituteName)
                                                .font(.subheadline.weight(.medium))
                                            Text(suggestion.detail)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    recipe.isFavorite.toggle()
                    try? modelContext.save()
                } label: {
                    Image(systemName: recipe.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(recipe.isFavorite ? .yellow : .primary)
                }
            }
        }
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
