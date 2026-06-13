import SwiftUI

struct GameModeButton: View {
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(20)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    GameModeButton(title: "Tap Frenzy", subtitle: "Tap fast.", color: .blue)
        .padding()
}