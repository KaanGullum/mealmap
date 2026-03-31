# MealMap Next Steps Roadmap

This document captures the next product and engineering improvements we want to explore after the current MVP snapshot.

## Current MVP Snapshot

The app already includes:

- onboarding and branded launch flow
- dashboard
- pantry management
- recipe list and custom recipe creation
- weekly planner
- shopping list generation
- local recommendation logic
- SwiftData-based local persistence

## Priority 1: High-Impact Product Improvements

### 1. Dashboard v2

Make the dashboard more action-oriented so the user can decide what to cook faster.

Planned improvements:

- add a `Tonight's Best Option` card
- show `Expiring Soon` with stronger urgency states
- display `Pantry Health` summary
- show weekly estimated spend based on current meal plan
- explain why a recipe is being recommended

Why it matters:

- improves first impression
- makes MealMap feel more useful immediately
- increases trust in recommendations

### 2. Faster Pantry Input

Reduce friction when adding and updating pantry items.

Planned improvements:

- quick-add pantry flow
- recently used items
- one-tap quantity adjustments
- low-stock indicator
- better category shortcuts

Why it matters:

- pantry maintenance is the highest-friction loop in the app
- faster input directly improves retention

### 3. Smarter Weekly Planning

Make planning feel closer to real household behavior.

Planned improvements:

- serving count support
- leftovers support
- carry meals into next-day lunch
- show estimated total weekly cost
- allow replacing meals without rebuilding the full plan

Why it matters:

- makes planning more realistic
- improves shopping list quality
- supports budget-conscious users better

## Priority 2: Recommendation and Shopping Quality

### 4. Explainable Recommendations

Improve trust by showing recommendation reasons directly in the UI.

Planned improvements:

- `Uses 4 pantry items`
- `Helps use 2 expiring ingredients`
- `Budget-friendly`
- `Only 1 missing item`

### 5. Better Recipe Filters

Planned improvements:

- `Can make now`
- `Missing 1 ingredient`
- `Budget-friendly`
- `High protein`
- `Quick meals`
- `Uses expiring items`

### 6. Better Shopping List Grouping

Planned improvements:

- group by grocery section
- highlight pantry shortages separately
- show estimated shopping cost
- merge unit-compatible duplicates more intelligently

## Priority 3: UX and Retention

### 7. Empty State and Success State Polish

Planned improvements:

- better empty pantry messaging
- friendlier no-recipe and no-plan states
- completion feedback when shopping list is finished
- celebratory micro-feedback when the user reduces waste

### 8. Personalization

Planned improvements:

- favorite recipes
- repeat weekly meals
- preferred meal types
- user budget profile
- pantry staples profile

## Future Bets

These are not immediate MVP tasks, but the codebase should stay ready for them.

- barcode scanning for pantry items
- OCR receipt import
- AI meal recommendation API
- nutrition tracking
- budget profiles
- multi-user household mode
- cloud sync
- seasonal suggestions
- store-aware shopping optimization

## Suggested Next Sprint

If we want the highest impact with manageable scope, the next sprint should focus on:

1. Dashboard v2
2. Faster pantry input
3. Smarter weekly planning with cost visibility

## Engineering Notes

While implementing the next wave, keep these technical goals in mind:

- preserve MVVM boundaries
- keep recommendation logic replaceable
- avoid coupling views directly to persistence details
- keep shopping list generation testable
- prepare a clean API service layer without introducing network dependency yet

