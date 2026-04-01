import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(.white)
                        .padding(18)
                        .background(Color.green.gradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                    Text("MealMap")
                        .font(.largeTitle.bold())

                    Text("Plan a week of meals around the ingredients you already have, catch items expiring soon, and keep your shopping list focused.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 14) {
                    OnboardingFeatureRow(
                        title: L10n.text("Pantry-aware suggestions"),
                        detail: L10n.text("Recipes are ranked by what you already own and what should be used soon."),
                        systemImage: "cabinet"
                    )
                    OnboardingFeatureRow(
                        title: L10n.text("Budget-friendly planning"),
                        detail: L10n.text("Keep lower-cost recipes front and center while building the week."),
                        systemImage: MealMapSymbols.cost
                    )
                    OnboardingFeatureRow(
                        title: L10n.text("Clean shopping list"),
                        detail: L10n.text("Only missing or insufficient ingredients are added, with duplicate items merged."),
                        systemImage: "cart"
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Label("Runs fully offline with local sample data", systemImage: "checkmark.seal")
                    Label("Built with SwiftUI + SwiftData", systemImage: "square.stack.3d.up")
                    Label("Ready for future API integration", systemImage: "bolt.horizontal")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Button("Start Planning", action: onContinue)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(24)
        }
        .background(
            LinearGradient(
                colors: [Color.green.opacity(0.08), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

private struct OnboardingFeatureRow: View {
    let title: String
    let detail: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.green)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onContinue: {})
    }
}
