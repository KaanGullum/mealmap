import SwiftUI

struct MealPlanPickerView: View {
    let date: Date
    let mealType: MealType
    let recipes: [Recipe]
    let plannedEntries: [MealPlanEntry]
    let currentEntryID: UUID?
    let selectedRecipeID: UUID?
    let selectedLeftoverSourceEntryID: UUID?
    let onSelectRecipe: (Recipe) -> Void
    let onSelectLeftovers: (MealPlanEntry) -> Void
    let onClear: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showClearConfirmation = false
    private let metricsService = MealPlanMetricsService()

    var body: some View {
        NavigationStack {
            List {
                if selectedRecipeID != nil {
                    Section {
                        Button(role: .destructive) {
                            showClearConfirmation = true
                        } label: {
                            Label(L10n.text("Clear Selection"), systemImage: "trash")
                        }
                    }
                }

                if leftoverCandidates.isEmpty == false {
                    Section(L10n.text("Use leftovers")) {
                        ForEach(leftoverCandidates, id: \.id) { sourceEntry in
                            Button {
                                onSelectLeftovers(sourceEntry)
                                dismiss()
                            } label: {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(recipeByID[sourceEntry.recipeID]?.title ?? L10n.text("Leftovers"))
                                            .foregroundStyle(.primary)
                                        Text(leftoverSubtitle(for: sourceEntry))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    if selectedLeftoverSourceEntryID == sourceEntry.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    }
                                }
                            }
                        }
                    }
                }

                if highlightedRecipes.isEmpty == false {
                    Section(L10n.text("Favorites & repeats")) {
                        ForEach(highlightedRecipes, id: \.id) { recipe in
                            recipeButton(for: recipe)
                        }
                    }
                }

                Section(L10n.text("Recipes")) {
                    ForEach(allRecipes, id: \.id) { recipe in
                        recipeButton(for: recipe)
                    }
                }
            }
            .navigationTitle(L10n.mealTypeAndDate(mealType.title, dateText: date.formatted(.dateTime.month().day())))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.text("Done")) {
                        dismiss()
                    }
                }
            }
            .alert(L10n.text("Clear Selection"), isPresented: $showClearConfirmation, actions: {
                Button(L10n.text("Cancel"), role: .cancel) {}
                Button(L10n.text("Clear"), role: .destructive) {
                    onClear()
                    dismiss()
                }
            }, message: {
                Text(L10n.text("This will remove the selected recipe from this meal slot."))
            })
        }
    }

    private var recipeByID: [UUID: Recipe] {
        Dictionary(uniqueKeysWithValues: recipes.map { ($0.id, $0) })
    }

    private var repeatCounts: [UUID: Int] {
        metricsService.recipeUsageCounts(entries: plannedEntries)
    }

    private var entriesAvailableForLeftoverPlanning: [MealPlanEntry] {
        plannedEntries.filter { $0.id != currentEntryID }
    }

    private var leftoverCandidates: [MealPlanEntry] {
        metricsService.eligibleLeftoverSources(for: date, entries: entriesAvailableForLeftoverPlanning)
    }

    private var highlightedRecipes: [Recipe] {
        recipes
            .filter { recipe in
                recipe.isFavorite || repeatCounts[recipe.id, default: 0] > 0
            }
            .sorted(by: sortRecipes)
    }

    private var allRecipes: [Recipe] {
        let highlightedIDs = Set(highlightedRecipes.map(\.id))
        return recipes
            .filter { highlightedIDs.contains($0.id) == false }
            .sorted(by: sortRecipes)
    }

    private func sortRecipes(_ lhs: Recipe, _ rhs: Recipe) -> Bool {
        let lhsRepeatCount = repeatCounts[lhs.id, default: 0]
        let rhsRepeatCount = repeatCounts[rhs.id, default: 0]

        if lhs.isFavorite != rhs.isFavorite {
            return lhs.isFavorite && rhs.isFavorite == false
        }

        if lhsRepeatCount != rhsRepeatCount {
            return lhsRepeatCount > rhsRepeatCount
        }

        return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
    }

    private func recipeButton(for recipe: Recipe) -> some View {
        Button {
            onSelectRecipe(recipe)
            dismiss()
        } label: {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(recipe.title)
                            .foregroundStyle(.primary)
                        if recipe.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }

                    Text(L10n.durationAndCost(minutes: recipe.prepTimeMinutes, costText: recipe.estimatedCost.currencyText))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Text(L10n.servings(recipe.defaultServings))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        if repeatCounts[recipe.id, default: 0] > 0 {
                            Text(L10n.repeatCount(repeatCounts[recipe.id, default: 0]))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                if selectedLeftoverSourceEntryID == nil, selectedRecipeID == recipe.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
    }

    private func leftoverSubtitle(for sourceEntry: MealPlanEntry) -> String {
        let dateText = sourceEntry.date.formatted(.dateTime.weekday(.abbreviated).day().month())
        let remainingServings = metricsService.remainingLeftoverServings(
            for: sourceEntry,
            entries: entriesAvailableForLeftoverPlanning
        )

        return L10n.leftoverAvailableSummary(
            mealType: sourceEntry.mealType.title,
            dateText: dateText,
            servings: remainingServings
        )
    }
}

struct MealPlanPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MealPlanPickerView(
            date: .now,
            mealType: .dinner,
            recipes: SampleDataFactory.sampleRecipes(),
            plannedEntries: SampleDataFactory.seedData().mealPlanEntries,
            currentEntryID: nil,
            selectedRecipeID: nil,
            selectedLeftoverSourceEntryID: nil,
            onSelectRecipe: { _ in },
            onSelectLeftovers: { _ in },
            onClear: {}
        )
    }
}
