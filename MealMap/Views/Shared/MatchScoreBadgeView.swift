import SwiftUI

struct MatchScoreBadgeView: View {
    let score: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
            Text("\(score)")
                .fontWeight(.semibold)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.green)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.green.opacity(0.12), in: Capsule())
    }
}

struct MatchScoreBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        MatchScoreBadgeView(score: 86)
            .padding()
    }
}
