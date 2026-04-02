import SwiftUI

@MainActor
struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @AppStorage("budgetFriendlyMode") private var budgetFriendlyMode = false
    @AppStorage("showOnlyAvailableRecipes") private var showOnlyAvailableRecipes = false
    @AppStorage("weeklyBudgetLimitEnabled") private var weeklyBudgetLimitEnabled = false
    @AppStorage("weeklyBudgetLimit") private var weeklyBudgetLimit = 700.0
    @AppStorage(L10n.appLanguagePreferenceKey) private var appLanguagePreferenceRawValue = AppLanguagePreference.system.rawValue

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: SettingsViewModel())
    }

    var body: some View {
        Form {
            Section(L10n.text("Language")) {
                Picker(L10n.text("App Language"), selection: $appLanguagePreferenceRawValue) {
                    ForEach(AppLanguagePreference.allCases) { option in
                        Text(L10n.text(option.titleKey)).tag(option.rawValue)
                    }
                }

                Text(L10n.text("Choose whether MealMap follows your iPhone language or always stays in English or Turkish."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section(L10n.text("Planning Preferences")) {
                Toggle(L10n.text("Enable budget-friendly suggestions"), isOn: $budgetFriendlyMode)
                Toggle(L10n.text("Default to “Can be made with what I already have”"), isOn: $showOnlyAvailableRecipes)
            }

            Section(L10n.text("Budget Guardrails")) {
                Toggle(L10n.text("Enable weekly budget cap"), isOn: $weeklyBudgetLimitEnabled)

                if weeklyBudgetLimitEnabled {
                    Stepper(value: $weeklyBudgetLimit, in: 100...5000, step: 50) {
                        Label(
                            L10n.budgetCapValue(weeklyBudgetLimit.currencyText),
                            systemImage: "wallet.pass"
                        )
                    }
                }
            }

            Section(L10n.text("Current Mode")) {
                Label(L10n.text("Local recommendation engine"), systemImage: "internaldrive")
                Text(viewModel.localModeDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(L10n.text("Settings"))
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
