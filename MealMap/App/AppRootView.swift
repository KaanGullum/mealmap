import SwiftData
import SwiftUI

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var hasPreparedApp = false
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            Group {
                if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                    }
                }
            }
            .opacity(isShowingSplash ? 0 : 1)
            .animation(.easeOut(duration: 0.35), value: isShowingSplash)

            if isShowingSplash {
                MealMapSplashView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
        .task {
            await prepareApp()
        }
    }

    @MainActor
    private func prepareApp() async {
        guard hasPreparedApp == false else {
            return
        }

        hasPreparedApp = true
        let launchBeganAt = Date()

        await SampleDataLoader().seedIfNeeded(in: modelContext)
        await waitMinimumSplashDuration(since: launchBeganAt)

        withAnimation(.easeInOut(duration: 0.45)) {
            isShowingSplash = false
        }
    }

    private func waitMinimumSplashDuration(since startDate: Date) async {
        let minimumDuration: TimeInterval = 0.8
        let elapsed = Date().timeIntervalSince(startDate)
        let remaining = max(0, minimumDuration - elapsed)

        guard remaining > 0 else {
            return
        }

        try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
    }
}
