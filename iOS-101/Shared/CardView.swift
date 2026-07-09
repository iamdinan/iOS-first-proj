//
//  CardView.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

struct CardView: View {
    let card: Card
    let glowColor: Color

    var body: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
            .fill(card.isLit ? glowColor : Theme.surface)
            .frame(height: 90)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                    .strokeBorder(card.isLit ? glowColor : glowColor.opacity(0.25), lineWidth: 2)
            )
            .shadow(color: card.isLit ? glowColor.opacity(0.8) : .clear, radius: 18)
            .scaleEffect(card.isLit ? 1.08 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: card.isLit)
    }
}
