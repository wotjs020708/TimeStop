//
//  HapticsProvider.swift
//  TimeStop
//
//  Created by Jaesun Eo on 2/2/26.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

// MARK: - Enums

/// Impact feedback intensity levels
enum ImpactStyle {
    case light
    case medium
    case heavy
}

/// Notification feedback types
enum NotificationType {
    case success
    case warning
    case error
}

// MARK: - Protocol

/// Abstraction for platform-specific haptic feedback
protocol HapticsProvider {
    /// Trigger impact feedback with specified intensity
    func impact(style: ImpactStyle)

    /// Trigger notification feedback with specified type
    func notification(type: NotificationType)
}

// MARK: - iOS Implementation

#if os(iOS)
/// iOS implementation using UIKit feedback generators
final class IOSHapticsProvider: HapticsProvider {
    func impact(style: ImpactStyle) {
        let generator = UIImpactFeedbackGenerator(style: mapImpactStyle(style))
        generator.impactOccurred()
    }

    func notification(type: NotificationType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(mapNotificationType(type))
    }

    // MARK: - Private Helpers

    private func mapImpactStyle(_ style: ImpactStyle) -> UIImpactFeedbackGenerator.FeedbackStyle {
        switch style {
        case .light:
            return .light
        case .medium:
            return .medium
        case .heavy:
            return .heavy
        }
    }

    private func mapNotificationType(_ type: NotificationType) -> UINotificationFeedbackGenerator.FeedbackType {
        switch type {
        case .success:
            return .success
        case .warning:
            return .warning
        case .error:
            return .error
        }
    }
}
#endif

// MARK: - watchOS Implementation

#if os(watchOS)
/// watchOS implementation using WatchKit haptics
final class WatchHapticsProvider: HapticsProvider {
    func impact(style: ImpactStyle) {
        let feedbackType = mapImpactStyle(style)
        WKInterfaceDevice.current().play(feedbackType)
    }

    func notification(type: NotificationType) {
        let feedbackType = mapNotificationType(type)
        WKInterfaceDevice.current().play(feedbackType)
    }

    // MARK: - Private Helpers

    private func mapImpactStyle(_ style: ImpactStyle) -> WKHapticType {
        switch style {
        case .light:
            return .click
        case .medium:
            return .notification
        case .heavy:
            return .notification
        }
    }

    private func mapNotificationType(_ type: NotificationType) -> WKHapticType {
        switch type {
        case .success:
            return .success
        case .warning:
            return .failure
        case .error:
            return .failure
        }
    }
}
#endif
