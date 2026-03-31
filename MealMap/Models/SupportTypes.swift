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
        case .piece: "pcs"
        case .gram: "g"
        case .kilogram: "kg"
        case .milliliter: "ml"
        case .liter: "L"
        case .cup: "cup"
        case .tablespoon: "tbsp"
        case .teaspoon: "tsp"
        case .can: "can"
        case .pack: "pack"
        case .slice: "slice"
        case .bunch: "bunch"
        case .loaf: "loaf"
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
        case .produce: "Produce"
        case .dairy: "Dairy"
        case .protein: "Protein"
        case .grains: "Grains"
        case .cannedGoods: "Canned"
        case .frozen: "Frozen"
        case .spices: "Spices"
        case .bakery: "Bakery"
        case .snacks: "Snacks"
        case .beverages: "Beverages"
        case .other: "Other"
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

    var title: String { rawValue.capitalized }

    var systemImage: String {
        switch self {
        case .breakfast: "sunrise"
        case .lunch: "sun.max"
        case .dinner: "moon.stars"
        }
    }
}
