import SwiftUI

struct CardView: View {
    let card: Card
    let glowColor: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(card.isLit ? glowColor : Color(.systemGray5))
            .frame(height: 90)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(card.isLit ? glowColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: card.isLit ? glowColor.opacity(0.7) : .clear, radius: 10)
            .scaleEffect(card.isLit ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: card.isLit)
    }
}

#Preview {
    CardView(card: Card(id: 0, isLit: true), glowColor: .cyan)
        .padding()
}