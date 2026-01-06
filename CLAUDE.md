# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TimeStop is a SwiftUI-based iOS application built with Xcode using **The Composable Architecture (TCA)**. The project targets iOS devices (iPhone and iPad) and uses Swift 5.0. This is a **global service** with localization support.

- **Bundle ID**: com.jaesuneo.TimeStop
- **Target Devices**: iPhone and iPad (TARGETED_DEVICE_FAMILY: 1,2)
- **iOS Deployment Target**: iOS 17.0+
- **Minimum Supported Device**: iPhone 13 mini (5.4", 2340x1080)
- **Marketing Version**: 1.0
- **Architecture**: TCA (The Composable Architecture)
- **UI Guidelines**: Apple Human Interface Guidelines (HIG)
- **Localization**: Multi-language support for global audience

## Build Commands

### Building the project
```bash
xcodebuild -project TimeStop.xcodeproj -scheme TimeStop -configuration Debug build
```

### Building for Release
```bash
xcodebuild -project TimeStop.xcodeproj -scheme TimeStop -configuration Release build
```

### Cleaning build artifacts
```bash
xcodebuild -project TimeStop.xcodeproj -scheme TimeStop clean
```

### Running tests
```bash
xcodebuild test -project TimeStop.xcodeproj -scheme TimeStop -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Project Structure

```
TimeStop/
├── TimeStopApp.swift       # App entry point (@main)
├── Features/               # Feature modules (TCA reducers, actions, states)
├── Views/                  # SwiftUI views following HIG
├── Resources/              # Localizable strings and assets
└── Assets.xcassets/        # App assets (icons, colors)
```

## Architecture: The Composable Architecture (TCA)

### Core TCA Concepts

**Features** are organized using TCA's pattern:
- **State**: Struct containing all feature state
- **Action**: Enum defining all possible actions
- **Reducer**: Pure function that evolves state based on actions
- **Environment/Dependencies**: External dependencies injected for testability

### Feature Module Structure

Each feature should follow this structure:
```swift
import ComposableArchitecture

@Reducer
struct FeatureName {
    @ObservableState
    struct State: Equatable {
        // Feature state properties
    }

    enum Action {
        // User actions, delegate actions, internal actions
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // State mutations and effects
        }
    }
}
```

### View Integration

Views should use `WithViewStore` or `@Perception.Bindable` to observe state:
```swift
struct FeatureView: View {
    let store: StoreOf<Feature>

    var body: some View {
        // SwiftUI view following HIG
    }
}
```

## UI Guidelines

- **Follow Apple HIG**: Use native iOS components, spacing, and patterns
- **System Colors**: Prefer semantic colors (`.primary`, `.secondary`, `.accentColor`)
- **Typography**: Use standard text styles (`.title`, `.headline`, `.body`, `.caption`)
- **Navigation**: Use SwiftUI navigation patterns (NavigationStack, sheets, alerts)
- **Accessibility**: Ensure VoiceOver support, Dynamic Type compatibility
- **SF Symbols**: Use SF Symbols for icons
- **Screen Size**: All UI must be optimized for iPhone 13 mini (375pt width)
  - Use compact spacing and padding (16-24pt horizontal, 20-32pt vertical)
  - Scale down font sizes appropriately (max 64pt for icons, 60pt for numbers)
  - Ensure all content fits without excessive scrolling

## Localization

- Use `LocalizedStringKey` for all user-facing strings
- Strings should be added to `Localizable.strings` or `.xcstrings` catalog
- Format: `Text("key_name")` - SwiftUI automatically looks up localized strings
- Support RTL languages where applicable
- Date/number formatting should respect locale

## Development Notes

- **Testing**: TCA enables comprehensive unit testing of business logic without UI
- **Dependencies**: Use TCA's dependency management system for testable code
- **Effects**: All side effects (API calls, timers, etc.) should be modeled as Effect types
- **Navigation**: Use TCA's navigation patterns (tree-based state, stack state)
- **Swift Features**:
  - Swift Approachable Concurrency enabled
  - MainActor default isolation
  - String catalog symbol generation enabled
  - Member import visibility upcoming feature enabled
