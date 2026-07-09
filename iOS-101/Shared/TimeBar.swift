//
//  TimeBar.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

/// Reusable timer progress bar + label.
func timerBar(current: Int, total: Int) -> some View {
    let color: Color = {
        let ratio = Double(current) / Double(total)
        if ratio > 0.6 { return Theme.neonGreen }
        if ratio > 0.3 { return .orange }
        return Theme.neonRed
    }()

    return VStack(spacing: 8) {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.surfaceLight)
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(current) / CGFloat(total))
                    .shadow(color: color.opacity(0.7), radius: 8)
                    .animation(.linear(duration: 0.9), value: current)
            }
        }
        .frame(height: 10)
        .padding(.horizontal, 28)

        Text("\(current)s")
            .font(.system(size: 22, weight: .black, design: .rounded))
            .foregroundStyle(color)
            .contentTransition(.numericText())
            .animation(.snappy, value: current)
    }
}
