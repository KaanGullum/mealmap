import Foundation

enum IngredientUnit: String, Codable, CaseIterable, Identifiable {
    case piece
    case gram
    case kilogram
    case milliliter
    case liter
    case cup
    case tablespoon
    case teaspoon
    case can
    case pack
    case slice
    case bunch
    case loaf

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .piece: L10n.text("pcs")
        case .gram: "g"
        case .kilogram: "kg"
        case .milliliter: "ml"
        case .liter: "L"
        case .cup: L10n.text("cup")
        case .tablespoon: L10n.text("tbsp")
        case .teaspoon: L10n.text("tsp")
        case .can: L10n.text("can")
        case .pack: L10n.text("pack")
        case .slice: L10n.text("slice")
        case .bunch: L10n.text("bunch")
        case .loaf: L10n.text("loaf")
        }
    }
}

enum PantryCategory: String, Codable, CaseIterable, Identifiable {
    case produce
    case dairy
    case protein
    case grains
    case cannedGoods
    case frozen
    case spices
    case bakery
    case snacks
    case beverages
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .produce: L10n.text("Produce")
        case .dairy: L10n.text("Dairy")
        case .protein: L10n.text("Protein")
        case .grains: L10n.text("Grains")
        case .cannedGoods: L10n.text("Canned")
        case .frozen: L10n.text("Frozen")
        case .spices: L10n.text("Spices")
        case .bakery: L10n.text("Bakery")
        case .snacks: L10n.text("Snacks")
        case .beverages: L10n.text("Beverages")
        case .other: L10n.text("Other")
        }
    }

    var systemImage: String {
        switch self {
        case .produce: "leaf"
        case .dairy: "drop"
        case .protein: "fish"
        case .grains: "bag"
        case .cannedGoods: "cylinder"
        case .frozen: "snowflake"
        case .spices: "flame"
        case .bakery: "birthday.cake"
        case .snacks: "takeoutbag.and.cup.and.straw"
        case .beverages: "wineglass"
        case .other: "square.grid.2x2"
        }
    }
}

enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast
    case lunch
    case dinner

    var id: String { rawValue }

    var title: String {
        switch self {
        case .breakfast: L10n.text("Breakfast")
        case .lunch: L10n.text("Lunch")
        case .dinner: L10n.text("Dinner")
        }
    }

    var systemImage: String {
        switch self {
        case .breakfast: "sunrise"
        case .lunch: "sun.max"
        case .dinner: "moon.stars"
        }
    }
}
