//
//  ButtonColor.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

enum ButtonColor: CaseIterable {
    case normal, green, grey

    var color: Color {
        switch self {
        case .normal: return Color(red: 0.0, green: 0.831, blue: 1.0) // cyan
        case .green:  return Theme.neonGreen
        case .grey:   return Theme.neonRed
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
