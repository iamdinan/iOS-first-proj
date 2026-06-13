import SwiftUI

enum ButtonColor: CaseIterable {
    case normal, green, grey

    var color: Color {
        switch self {
        case .normal: return .blue
        case .green:  return .green
        case .grey:   return Color(.systemGray3)
        }
    }

    var label: String {
        switch self {
        case .normal: return "TAP!"
        case .green:  return "BONUS!"
        case .grey:   return "TRAP!"
        }
    }
}