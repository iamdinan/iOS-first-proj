import SwiftUI

// MARK: - Card
struct Card: Identifiable {
    let id: Int
    var isLit: Bool = false
}

// MARK: - Level
struct LIULevel {
    let number: Int
    let columns: Int
    let rows: Int
    let litWindow: Double
    let litCount: Int
    let glowColor: Color

    var totalCards: Int { columns * rows }

    var timeRange: ClosedRange<Int> {
        switch number {
        case 1: return 46...60
        case 2: return 31...45
        case 3: return 16...30
        default: return 0...15
        }
    }

    static let all: [LIULevel] = [
        LIULevel(number: 1, columns: 3, rows: 1, litWindow: 1.5, litCount: 1, glowColor: .cyan),
        LIULevel(number: 2, columns: 4, rows: 1, litWindow: 1.2, litCount: 1, glowColor: .green),
        LIULevel(number: 3, columns: 3, rows: 2, litWindow: 1.0, litCount: 1, glowColor: .orange),
        LIULevel(number: 4, columns: 3, rows: 3, litWindow: 0.8, litCount: 2, glowColor: .red),
    ]

    static func current(for timeLeft: Int) -> LIULevel {
        all.first { $0.timeRange.contains(timeLeft) } ?? all[3]
    }
}