import SwiftUI

enum AppTab: Hashable {
    case dashboard
    case pantry
    case recipes
    case planner
    case shoppingList
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView(selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }
            .tag(AppTab.dashboard)

            NavigationStack {
                PantryView()
            }
            .tabItem {
                Label("Pantry", systemImage: "cabinet")
            }
            .tag(AppTab.pantry)

            NavigationStack {
                RecipesView()
            }
            .tabItem {
                Label("Recipes", systemImage: "fork.knife")
            }
            .tag(AppTab.recipes)

            NavigationStack {
                WeeklyPlannerView()
            }
            .tabItem {
                Label("Planner", systemImage: "calendar")
            }
            .tag(AppTab.planner)

            NavigationStack {
                ShoppingListView()
            }
            .tabItem {
                Label("Shopping", systemImage: "cart")
            }
            .tag(AppTab.shoppingList)
        }
        .tint(.green)
    }
}
