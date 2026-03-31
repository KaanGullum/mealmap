# MealMap

MealMap is an iOS 17+ SwiftUI app for pantry-aware weekly meal planning. It runs entirely offline using SwiftData, ships with local sample data, and is structured so a future API-backed recommendation layer can be plugged in without rewriting the app.

## MVP Highlights

- Pantry management with quantity, unit, category, staple flag, and expiration date
- Recipe library with custom recipe creation, tags, prep time, and estimated cost
- Dashboard with expiring-soon items, quick actions, and ranked meal suggestions
- Weekly planner with per-day meal slots
- Auto-generated shopping list that only includes missing or insufficient ingredients
- Budget-friendly mode and a `Can be made with what I already have` filter
- Local unit tests for recommendation ranking and shopping list generation

## Architecture

The project follows a lightweight MVVM structure:

- `MealMap/App`
  App entry, root flow, onboarding, and tab shell
- `MealMap/Models`
  SwiftData models plus lightweight recommendation and shopping DTOs
- `MealMap/ViewModels`
  Screen-specific presentation and orchestration logic
- `MealMap/Views`
  SwiftUI screens grouped by feature
- `MealMap/Services`
  Rule-based recommendation engine, shopping list generator, categorization, and sample data loading
- `MealMap/Persistence`
  SwiftData model container creation
- `MealMap/MockData`
  Seed data for immediate local testing
- `MealMap/Utilities`
  Formatting and date helpers
- `MealMapTests`
  Unit tests for the recommendation engine and shopping list generation

## Recommendation Logic

The local recommendation engine is intentionally simple and replaceable.

- Recipes score higher when they use more pantry ingredients
- Recipes score higher when they consume ingredients expiring soon
- Budget-friendly mode boosts lower-cost recipes
- Pantry-only mode filters down to recipes that are fully covered by current inventory
- Results expose a match score and ingredient coverage summary

The integration seam for a future AI/API service lives in `RecipeRecommendationServicing`.

## Shopping List Logic

The shopping list generator:

- looks at all selected weekly meal plan entries
- aggregates recipe ingredient requirements
- subtracts pantry quantities with exact name and unit matching
- merges duplicates
- only returns missing or insufficient ingredients

## Running The App

1. Open [`MealMap.xcodeproj`](/Users/kaangullu/Desktop/MealMap/MealMap/MealMap.xcodeproj) in Xcode.
2. Choose the `MealMap` scheme.
3. Run on any iOS 17+ simulator or device.
4. On first launch, the app seeds local sample pantry items, recipes, and a few meal plan entries automatically.

## Running Tests

Use the `MealMap` scheme and run the `MealMapTests` test target in Xcode, or from Terminal:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project MealMap.xcodeproj \
  -scheme MealMap \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test
```

## Future Improvements

These are also captured as in-code TODOs:

- Barcode scanning for pantry items
- OCR receipt import
- AI meal recommendation API
- Nutrition tracking
- User budget profiles
- Multi-user household mode
- Cloud sync
