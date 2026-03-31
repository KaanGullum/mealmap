import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.green)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let buttonTitle, let action {
                Button(buttonTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(
            title: "No Items Yet",
            message: "Start by adding pantry staples or sample meals.",
            systemImage: "cabinet"
        )
        .padding()
    }
}
