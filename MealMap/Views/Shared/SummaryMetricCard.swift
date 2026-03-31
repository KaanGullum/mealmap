import SwiftUI

struct SummaryMetricCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(.green)

            Text(value)
                .font(.title3.weight(.bold))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct SummaryMetricCard_Previews: PreviewProvider {
    static var previews: some View {
        SummaryMetricCard(title: "Expiring Soon", value: "3", systemImage: "clock")
            .padding()
    }
}
