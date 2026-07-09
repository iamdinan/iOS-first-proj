//
//  Theme.swift
//  iOS-101
//
//  Created by Dinan Dilmith on 2026-07-09.
//

import SwiftUI

enum Theme {
    static let background = Color(red: 0.051, green: 0.051, blue: 0.078)
    static let surface     = Color(red: 0.102, green: 0.102, blue: 0.149)
    static let surfaceLight = Color(red: 0.145, green: 0.145, blue: 0.20)
    static let textPrimary   = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let textSecondary = Color(red: 0.541, green: 0.541, blue: 0.588)

    static let neonGreen  = Color(red: 0.224, green: 1.0, blue: 0.078)
    static let neonRed    = Color(red: 1.0, green: 0.231, blue: 0.231)

    enum Radius {
        static let xl: CGFloat = 28
        static let card: CGFloat = 24
        static let small: CGFloat = 16
    }
}

extension GameMode {
    var themeColor: Color {
        switch self {
        case .tapFrenzy: return Color(red: 0.0, green: 0.831, blue: 1.0)   // neon cyan
        case .lightItUp: return Color(red: 0.690, green: 0.149, blue: 1.0) // neon violet
        case .quizRush:  return Color(red: 1.0, green: 0.180, blue: 0.573) // neon magenta
        }
    }
}

/// Glowing arcade card — used for CardView, ResultView blocks, high score rows, home mode buttons
struct ArcadeCard: ViewModifier {
    var accent: Color
    var radius: CGFloat = Theme.Radius.card
    var glow: Bool = true
    func body(content: Content) -> some View {
        content
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(accent.opacity(0.7), lineWidth: 2)
            )
            .shadow(color: glow ? accent.opacity(0.45) : .clear, radius: 16, x: 0, y: 0)
    }
}

extension View {
    func arcadeCard(accent: Color, radius: CGFloat = Theme.Radius.card, glow: Bool = true) -> some View {
        modifier(ArcadeCard(accent: accent, radius: radius, glow: glow))
    }
}

/// Chunky primary button with press-bounce + glow
struct ArcadeButtonStyle: ButtonStyle {
    let accent: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 22, weight: .black, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(accent)
            .foregroundStyle(Theme.background)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .shadow(color: accent.opacity(configuration.isPressed ? 0.2 : 0.6), radius: configuration.isPressed ? 6 : 16)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

/// Secondary/ghost button — outline only, still neon
struct ArcadeGhostButtonStyle: ButtonStyle {
    let accent: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(accent)
            .background(Theme.surfaceLight)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.small).strokeBorder(accent.opacity(0.5), lineWidth: 1.5))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: configuration.isPressed)
    }
}
