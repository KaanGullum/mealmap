import SwiftUI

struct MealMapSplashView: View {
    @State private var isBreathing = false

    var body: some View {
        ZStack {
            MealMapBrand.launchBackground
                .ignoresSafeArea()

            Circle()
                .fill(MealMapBrand.glow.opacity(0.16))
                .frame(width: 280, height: 280)
                .blur(radius: isBreathing ? 36 : 24)
                .scaleEffect(isBreathing ? 1.05 : 0.94)

            VStack(spacing: 22) {
                ZStack {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.059, green: 0.439, blue: 0.412),
                                    Color(red: 0.090, green: 0.231, blue: 0.333)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image("LaunchLogo")
                        .resizable()
                        .interpolation(.high)
                        .scaledToFill()
                        .scaleEffect(1.035)
                }
                .frame(width: 156, height: 156)
                .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                .shadow(color: MealMapBrand.shadow.opacity(0.16), radius: 22, y: 12)

                VStack(spacing: 8) {
                    Text("MealMap")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(MealMapBrand.title)

                    Text("Cook more from what you already have.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(MealMapBrand.subtitle)
                }
            }
            .padding(.horizontal, 32)
        }
        .task {
            guard isBreathing == false else {
                return
            }

            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        }
    }
}

struct MealMapSplashView_Previews: PreviewProvider {
    static var previews: some View {
        MealMapSplashView()
    }
}
