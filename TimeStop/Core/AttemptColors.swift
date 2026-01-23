//
//  AttemptColors.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI

/// Shared color palette for attempts - used in both Timer and Results screens
/// Colors adapt to light/dark mode using environment color scheme
enum AttemptColors {
    /// Base hue values for each color in the palette
    private static let hues: [Double] = [0.6, 0.35, 0.08, 0.75, 0.95, 0.5]

    /// Get color for attempt index, adapting to current color scheme
    static func color(for index: Int, colorScheme: ColorScheme = .light) -> Color {
        let hue = hues[index % hues.count]
        let brightness = colorScheme == .dark ? 0.6 : 0.8
        let saturation = colorScheme == .dark ? 0.8 : 0.7

        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    /// Darker version for background transitions
    static func transitionColor(for index: Int, colorScheme: ColorScheme = .light) -> Color {
        color(for: index, colorScheme: colorScheme).opacity(1.0)
    }

    /// Get gradient colors for timer background
    static func gradientColors(for index: Int, colorScheme: ColorScheme = .light) -> [Color] {
        let hue = hues[index % hues.count]
        let baseBrightness = colorScheme == .dark ? 0.25 : 0.3
        let saturation = colorScheme == .dark ? 0.9 : 0.8

        return [
            Color(hue: hue, saturation: saturation, brightness: baseBrightness),
            Color(hue: hue + 0.05, saturation: saturation - 0.1, brightness: baseBrightness - 0.1)
        ]
    }
}
