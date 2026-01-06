//
//  AttemptColors.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI

/// Shared color palette for attempts - used in both Timer and Results screens
enum AttemptColors {
    static let palette: [Color] = [
        Color(hue: 0.6, saturation: 0.7, brightness: 0.8),   // Blue
        Color(hue: 0.35, saturation: 0.7, brightness: 0.7),  // Green
        Color(hue: 0.08, saturation: 0.7, brightness: 0.85), // Orange
        Color(hue: 0.75, saturation: 0.6, brightness: 0.8),  // Purple
        Color(hue: 0.95, saturation: 0.6, brightness: 0.85), // Pink
        Color(hue: 0.5, saturation: 0.7, brightness: 0.75),  // Teal
    ]

    static func color(for index: Int) -> Color {
        palette[index % palette.count]
    }

    /// Darker version for background transitions
    static func transitionColor(for index: Int) -> Color {
        let baseColor = palette[index % palette.count]
        // Extract hue and create darker version
        return baseColor.opacity(1.0)
    }

    /// Get gradient colors for timer background
    static func gradientColors(for index: Int) -> [Color] {
        let hue = hueValue(for: index)
        return [
            Color(hue: hue, saturation: 0.8, brightness: 0.3),
            Color(hue: hue + 0.05, saturation: 0.7, brightness: 0.2)
        ]
    }

    private static func hueValue(for index: Int) -> Double {
        let hues: [Double] = [0.6, 0.35, 0.08, 0.75, 0.95, 0.5]
        return hues[index % hues.count]
    }
}
