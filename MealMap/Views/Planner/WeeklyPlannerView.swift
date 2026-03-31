import SwiftData
import SwiftUI

struct WeeklyPlannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealPlanEntry.date) private var mealPlanEntries: [MealPlanEntry]
    @Query(sort: \Recipe.title) private var recipes: [Recipe]
    @Query(sort: \PantryItem.name) private var pantryItems: [PantryItem]
    @Query(sort: \ShoppingListItem.name) private var shoppingListItems: [ShoppingListItem]
    @StateObject private var viewModel = PlannerViewModel()
    @State private var selectionContext: PlannerSelectionContext?
    @State private var shoppingListMessage: String?

    init() {}

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Build your week")
                        .font(.headline)
                    Text("Pick recipes for each meal slot, then generate a shopping list for anything still missing.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        SummaryMetricCard(
                            title: "Planned Meals",
                            value: "\(mealPlanEntries.count)",
                            systemImage: "calendar"
                        )
                        SummaryMetricCard(
                            title: "Weekly Cost",
                            value: viewModel.weeklyEstimatedCost(entries: mealPlanEntries, recipes: recipes).currencyText,
                            systemImage: "dollarsign.circle"
                        )
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }

            ForEach(viewModel.weekDates, id: \.self) { date in
                Section(date.formatted(.dateTime.weekday(.wide).day().month())) {
                    ForEach(MealType.allCases) { mealType in
                        let entry = viewModel.entry(for: date, mealType: mealType, entries: mealPlanEntries)
                        let recipe = viewModel.recipe(for: entry, recipes: recipes)

                        Button {
                            selectionContext = PlannerSelectionContext(date: date, mealType: mealType)
                        } label: {
                            HStack {
                                Label(mealType.title, systemImage: mealType.systemImage)
                                    .foregroundStyle(.primary)

                                Spacer()

                                if let recipe {
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(recipe.title)
                                            .font(.subheadline.weight(.medium))
                                        Text(recipe.estimatedCost.currencyText)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                } else {
                                    Text("Choose recipe")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }

            Section {
                Button {
                    generateShoppingList()
                } label: {
                    Label("Generate Shopping List", systemImage: "cart.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Weekly Planner")
        .sheet(item: $selectionContext) { context in
            MealPlanPickerView(
                date: context.date,
                mealType: context.mealType,
                recipes: recipes,
                selectedRecipeID: viewModel.entry(for: context.date, mealType: context.mealType, entries: mealPlanEntries)?.recipeID,
                onSelect: { recipe in
                    try? viewModel.assign(
                        recipe: recipe,
                        for: context.date,
                        mealType: context.mealType,
                        existingEntries: mealPlanEntries,
                        in: modelContext
                    )
                },
                onClear: {
                    try? viewModel.clearMeal(
                        for: context.date,
                        mealType: context.mealType,
                        existingEntries: mealPlanEntries,
                        in: modelContext
                    )
                }
            )
        }
        .alert("Shopping List Updated", isPresented: Binding(
            get: { shoppingListMessage != nil },
            set: { isPresented in
                if isPresented == false {
                    shoppingListMessage = nil
                }
            }
        ), actions: {
            Button("OK") {
                shoppingListMessage = nil
            }
        }, message: {
            Text(shoppingListMessage ?? "")
        })
    }

    private func generateShoppingList() {
        do {
            let count = try viewModel.generateShoppingList(
                pantryItems: pantryItems,
                plannedEntries: mealPlanEntries,
                recipes: recipes,
                existingItems: shoppingListItems,
                in: modelContext
            )
            shoppingListMessage = count == 0
                ? "Everything needed for your planned meals is already in the pantry."
                : "\(count) missing items were added to the shopping list."
        } catch {
            shoppingListMessage = "Unable to generate the shopping list right now."
        }
    }
}

struct WeeklyPlannerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeeklyPlannerView()
        }
        .modelContainer(ModelContainerFactory.makePreviewContainer())
    }
}
