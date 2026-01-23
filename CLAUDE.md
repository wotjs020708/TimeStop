# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TimeSense (formerly TimeStop) is a SwiftUI-based iOS timer game built with Xcode using **MVI (Model-View-Intent)** architecture. The project targets iPhone devices and uses Swift 5.0 with localization support for English and Korean.

- **Bundle ID**: com.jaesuneo.TimeStop
- **Target Devices**: iPhone (TARGETED_DEVICE_FAMILY: 1)
- **iOS Deployment Target**: iOS 17.0+
- **Minimum Supported Device**: iPhone 13 mini (5.4", 2340x1080)
- **Marketing Version**: 1.0
- **Architecture**: Custom MVI with Combine
- **UI Framework**: SwiftUI following Apple HIG
- **Localization**: English and Korean (.xcstrings catalog)

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

### Running tests (if added)
```bash
xcodebuild test -project TimeStop.xcodeproj -scheme TimeStop -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Project Structure

```
TimeStop/
├── TimeStopApp.swift       # App entry point (@main)
├── ContentView.swift       # Root view with navigation & tabs
├── Core/                   # Shared utilities and protocols
│   ├── MVIProtocols.swift      # Base MVI architecture
│   ├── AttemptColors.swift     # Color palette for attempts
│   └── HistoryManager.swift    # UserDefaults persistence
├── Presentation/           # Screen modules (View + ViewModel pairs)
│   ├── Onboarding/
│   ├── TimeInput/
│   ├── Timer/
│   ├── Results/
│   └── History/
└── Resources/
    └── Localizable.xcstrings   # String catalog (EN/KO)
```

## Architecture: MVI (Model-View-Intent)

This project uses a **custom MVI architecture** with Combine, defined in `Core/MVIProtocols.swift`.

### Core MVI Pattern

Each feature follows a consistent pattern with three components:

**1. State** - Immutable struct representing UI state:
```swift
struct FeatureViewState: ViewState {
    var property: Type
    // All mutable state lives here
}
```

**2. Intent** - Enum defining all user actions:
```swift
enum FeatureIntent: ViewIntent {
    case userTappedButton
    case valueChanged(String)
}
```

**3. ViewModel** - Manages state and handles intents:
```swift
@MainActor
final class FeatureViewModel: ViewModel<FeatureViewState, FeatureIntent, FeatureSideEffect> {
    override func send(_ intent: FeatureIntent) {
        switch intent {
        case .userTappedButton:
            updateState { $0.property = newValue }
        }
    }
}
```

**4. SideEffect (optional)** - Navigation or one-time events:
```swift
enum FeatureSideEffect: ViewSideEffect {
    case navigateToNextScreen
}
```

### Key MVI Concepts

- **Unidirectional data flow**: View → Intent → ViewModel → State → View
- **State immutability**: Use `updateState { }` to modify state
- **MainActor isolation**: All ViewModels are @MainActor for thread safety
- **Side effects**: Use `emitSideEffect()` for navigation/alerts, observe via Combine
- **Published state**: ViewModels use `@Published private(set) var state` for reactive updates

### Example: Timer Feature

See `Presentation/Timer/` for a complete MVI implementation:
- `TimerViewState`: Tracks timer state, elapsed time, attempts
- `TimerIntent`: User actions (start, stop, finish)
- `TimerSideEffect`: Navigation to results screen
- `TimerViewModel`: Manages timer Task, state updates, and side effects
- `TimerScreen`: SwiftUI view observing ViewModel

## Navigation Architecture

The app uses **SwiftUI NavigationStack** with enum-based routing:

```swift
enum Screen: Hashable {
    case onboarding
    case timeInput
    case timer(targetSeconds: Int)
    case results(targetSeconds: Int, attempts: [Attempt])
}
```

- **Root**: `ContentView` → TabView (Timer flow + History)
- **Timer flow**: NavigationStack with `[Screen]` path
- **Navigation pattern**: Screens append to path, results pop to root
- **Tab hiding**: `.toolbar(.hidden, for: .tabBar)` during timer/results

## Data Persistence

**HistoryManager** (singleton) manages session history:
- **Storage**: UserDefaults with JSON encoding
- **Model**: `TimerSession` contains target, attempts, timestamp
- **Operations**: `addSession()`, `deleteSession()`, `clearAllSessions()`
- **Usage**: Automatically persists after each session completion

## UI Guidelines

- **Apple HIG compliance**: Use native iOS components and patterns
- **Color system**:
  - Semantic colors (`.primary`, `.secondary`) for text - automatically adaptive
  - `AttemptColors` palette (6 colors) for timer backgrounds - supports dark mode
  - All screens use `@Environment(\.colorScheme)` to pass color scheme to AttemptColors
- **Dark Mode Support**:
  - Fully supports system dark mode (no forced color scheme)
  - AttemptColors adapts brightness/saturation based on color scheme
    - Light mode: brightness 0.8, saturation 0.7
    - Dark mode: brightness 0.6, saturation 0.8
  - Button text colors invert for proper contrast:
    - Light mode: white text on dark background
    - Dark mode: black text on light background
- **Typography**: Standard text styles (`.title`, `.headline`, `.body`)
- **SF Symbols**: For tab bar icons and UI elements
- **Screen optimization**:
  - Target: iPhone 13 mini (375pt width)
  - Compact spacing: 16-24pt horizontal, 20-32pt vertical
  - Max font sizes: 64pt icons, 60pt numbers
  - Ensure content fits without excessive scrolling

## Localization

- **String catalog**: `Resources/Localizable.xcstrings`
- **Supported languages**: English (base), Korean
- **Usage**: `Text("key_name")` - SwiftUI auto-localizes
- **Format**: String catalog with automatic symbol generation enabled
- **Number formatting**: Use `.formatted()` to respect locale

## Development Notes

- **Concurrency**: Swift async/await with Task-based timers
- **Timer precision**: 10ms update interval (see `TimerViewModel`)
- **Haptics**: `UINotificationFeedbackGenerator` for finish action
- **State management**: Combine's `@Published` for reactive updates
- **Memory management**: Cancel Tasks in `deinit` to prevent leaks
- **Navigation state**: Stored in `@State private var navigationPath: [Screen]`
