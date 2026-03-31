import SwiftUI

struct TagChipView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.12), in: Capsule())
    }
}

struct TagChipView_Previews: PreviewProvider {
    static var previews: some View {
        TagChipView(title: "Budget")
            .padding()
    }
}
