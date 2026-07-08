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
        if ratio > 0.6 { return .green }
        if ratio > 0.3 { return .orange }
        return .red
    }()

    return VStack(spacing: 8) {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color(.systemGray5))
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(current) / CGFloat(total))
                    .animation(.linear(duration: 0.9), value: current)
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 28)

        Text("\(current)s")
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .foregroundStyle(color)
            .contentTransition(.numericText())
            .animation(.snappy, value: current)
    }
}
