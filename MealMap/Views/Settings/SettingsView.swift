import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("budgetFriendlyMode") private var budgetFriendlyMode = false
    @AppStorage("showOnlyAvailableRecipes") private var showOnlyAvailableRecipes = false

    var body: some View {
        Form {
            Section("Planning Preferences") {
                Toggle("Enable budget-friendly suggestions", isOn: $budgetFriendlyMode)
                Toggle("Default to “Can be made with what I already have”", isOn: $showOnlyAvailableRecipes)
            }

            Section("Current Mode") {
                Label("Local recommendation engine", systemImage: "internaldrive")
                Text(viewModel.localModeDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Future API Integration") {
                ForEach(viewModel.roadmapItems, id: \.self) { item in
                    Label(item, systemImage: "circle.dotted")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
