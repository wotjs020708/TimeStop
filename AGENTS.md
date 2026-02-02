# AGENTS.md

Agent guidance for TimeSense (TimeStop) iOS project - SwiftUI MVI architecture.

## Project Context

**TimeSense** is a SwiftUI-based iOS timer game using custom MVI (Model-View-Intent) architecture.
- **Target**: iOS 17.0+, iPhone only (minimum: iPhone 13 mini, 375pt width)
- **Languages**: Swift 5.0, localized in English and Korean
- **Architecture**: Custom MVI with Combine (see `Core/MVIProtocols.swift`)
- **Bundle ID**: com.jaesuneo.TimeStop

## Build Commands

### Building
```bash
# Debug build (default)
xcodebuild -project TimeStop.xcodeproj -scheme TimeStop -configuration Debug build

# Release build
xcodebuild -project TimeStop.xcodeproj -scheme TimeStop -configuration Release build

# Clean build artifacts
xcodebuild -project TimeStop.xcodeproj -scheme TimeStop clean
```

### Testing
```bash
# Run all tests (if tests exist)
xcodebuild test -project TimeStop.xcodeproj -scheme TimeStop \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run specific test class
xcodebuild test -project TimeStop.xcodeproj -scheme TimeStop \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:TimeStopTests/ClassNameTests

# Run single test method
xcodebuild test -project TimeStop.xcodeproj -scheme TimeStop \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:TimeStopTests/ClassNameTests/testMethodName
```

**Note**: No tests currently exist in the project. When adding tests, create them in a `TimeStopTests` target.

## Architecture: MVI Pattern

This project follows **strict MVI (Model-View-Intent)** as defined in `Core/MVIProtocols.swift`.

### MVI Structure (MANDATORY for all features)

Every feature module MUST have these components:

1. **State** (struct conforming to `ViewState`):
   - Immutable struct representing complete UI state
   - All properties should be value types when possible
   - Must conform to `Equatable`

2. **Intent** (enum conforming to `ViewIntent`):
   - Enum defining all user actions
   - Use descriptive names: `.userTappedButton`, not `.buttonTap`
   - Include associated values for data: `.valueChanged(String)`

3. **ViewModel** (class inheriting `ViewModel<State, Intent, SideEffect>`):
   - MUST be `@MainActor` isolated
   - MUST be `final class`
   - Override `send(_ intent:)` to handle all intents
   - Use `updateState { }` to modify state (NEVER direct assignment)
   - Use `emitSideEffect()` for navigation/one-time events

4. **SideEffect** (enum conforming to `ViewSideEffect`, optional):
   - Use for navigation, alerts, or one-time events
   - NOT for state changes (use State for that)

### MVI Rules

- ✅ **DO**: Use `updateState { $0.property = value }` to modify state
- ✅ **DO**: Mark ViewModels as `@MainActor final class`
- ✅ **DO**: Use `nonisolated deinit` when canceling Tasks
- ✅ **DO**: Observe side effects via Combine: `.onReceive(viewModel.sideEffect)`
- ❌ **DON'T**: Directly assign to state: `state.property = value`
- ❌ **DON'T**: Put business logic in Views (Views only render and send intents)
- ❌ **DON'T**: Use StateObject/ObservedObject for anything except the ViewModel

### Example Pattern
```swift
// State
struct FeatureViewState: ViewState {
    var isLoading: Bool = false
    var items: [Item] = []
}

// Intent
enum FeatureIntent: ViewIntent {
    case loadTapped
    case itemSelected(Item)
}

// SideEffect
enum FeatureSideEffect: ViewSideEffect {
    case navigateToDetail(Item)
}

// ViewModel
@MainActor
final class FeatureViewModel: ViewModel<FeatureViewState, FeatureIntent, FeatureSideEffect> {
    override func send(_ intent: FeatureIntent) {
        switch intent {
        case .loadTapped:
            updateState { $0.isLoading = true }
            // Load data...
        case .itemSelected(let item):
            emitSideEffect(.navigateToDetail(item))
        }
    }
}

// View
struct FeatureScreen: View {
    @StateObject private var viewModel: FeatureViewModel
    
    var body: some View {
        // Render based on viewModel.state
        // Send intents: viewModel.send(.loadTapped)
        // Observe side effects: .onReceive(viewModel.sideEffect)
    }
}
```

## Code Style Guidelines

### Imports
- Import only what you need: `SwiftUI`, `Combine`, `Foundation`
- Group imports in this order:
  1. Apple frameworks (`SwiftUI`, `Combine`, `UIKit`)
  2. Third-party dependencies (none currently)
  3. Internal modules (if needed)
- No wildcard imports

### File Headers
```swift
//
//  FileName.swift
//  TimeStop
//
//  Created by [Name] on M/D/YY.
//
```

### Naming Conventions

- **Types**: PascalCase (`TimerViewModel`, `AttemptColors`)
- **Variables/Functions**: camelCase (`targetSeconds`, `startTimer()`)
- **Constants**: camelCase (`userDefaultsKey`, not `USER_DEFAULTS_KEY`)
- **Enums**: PascalCase for type, camelCase for cases
  ```swift
  enum TimerState { case ready, running, stopped }
  ```
- **Private properties**: Use `private` liberally, `private(set)` for published state
- **Booleans**: Use `is`, `has`, `should` prefixes (`isLoading`, `hasCompletedOnboarding`)

### Formatting

- **Indentation**: 4 spaces (NOT tabs)
- **Line length**: Aim for 100 chars, hard limit 120
- **Braces**: Same line for functions/types, can be on new line for long signatures
  ```swift
  func shortFunction() {
      // code
  }
  
  func longFunctionWithManyParameters(
      parameter1: String,
      parameter2: Int
  ) -> Result {
      // code
  }
  ```
- **Spacing**: One blank line between functions, two between types
- **Trailing commas**: Use in multi-line arrays/dicts for cleaner diffs

### Type Annotations

- **Explicit types** when it improves clarity:
  ```swift
  let targetSeconds: Int = 10  // Clear intent
  ```
- **Inferred types** when obvious:
  ```swift
  let impact = UIImpactFeedbackGenerator(style: .medium)  // Type is clear
  ```
- **Published properties**: Always explicit type
  ```swift
  @Published private(set) var state: TimerViewState
  ```

### Optionals

- **Prefer optional chaining** over force unwrapping:
  ```swift
  guard let value = optional else { return }  // ✅
  let value = optional!                        // ❌ Never
  ```
- **Use `guard let`** for early returns, `if let` for scoped usage
- **Avoid implicitly unwrapped optionals** (`var foo: String!`) unless required by framework

### Error Handling

- **Use `Result` type** for operations that can fail:
  ```swift
  func loadData() -> Result<Data, Error>
  ```
- **Try-catch** for synchronous errors:
  ```swift
  do {
      let data = try JSONEncoder().encode(sessions)
  } catch {
      // Handle error
  }
  ```
- **Optional try** (`try?`) only when failure is expected and can be ignored:
  ```swift
  try? await Task.sleep(nanoseconds: 10_000_000)  // Sleep cancellation is OK
  ```
- **Never** use empty catch blocks - at minimum log the error

### Concurrency

- **Use Swift Concurrency** (async/await, Task) over Grand Central Dispatch
- **Cancel Tasks in deinit**:
  ```swift
  nonisolated deinit {
      timerTask?.cancel()
  }
  ```
- **Check for cancellation** in long-running Tasks:
  ```swift
  while !Task.isCancelled {
      // work
  }
  ```
- **MainActor for ViewModels**: All ViewModels are `@MainActor` by default

### SwiftUI Specifics

- **State management**:
  - `@StateObject` for ViewModels (owned by view)
  - `@State` for local view state (navigation paths, UI state)
  - `@Environment` for system values (`.colorScheme`)
- **Modifiers order**: Layout → Behavior → Styling
  ```swift
  Text("Hello")
      .frame(maxWidth: .infinity)          // Layout
      .onTapGesture { }                    // Behavior
      .foregroundStyle(.primary)           // Styling
  ```
- **Previews**: Include `#Preview` for all screens

## Navigation

- **Enum-based routing**: Use `Screen` enum (see `ContentView.swift`)
  ```swift
  enum Screen: Hashable {
      case timer(targetSeconds: Int)
      case results(targetSeconds: Int, attempts: [Attempt])
  }
  ```
- **NavigationStack with path**: `@State private var navigationPath: [Screen]`
- **Hide tab bar during flows**: `.toolbar(.hidden, for: .tabBar)`
- **Pop to root**: `navigationPath = []`

## Localization

- **String catalog**: `Resources/Localizable.xcstrings` (EN/KO)
- **Usage**: `Text("key_name")` - SwiftUI auto-localizes
- **Keys**: Use snake_case (`timer_tab`, `hold_to_finish`)
- **Number formatting**: Use `.formatted()` to respect locale

## UI Guidelines

- **Target device**: iPhone 13 mini (375pt width) - test all layouts here
- **Spacing**: 16-24pt horizontal, 20-32pt vertical
- **Max font sizes**: 64pt icons, 60pt numbers
- **Colors**:
  - Use semantic colors (`.primary`, `.secondary`) for text
  - Use `AttemptColors.color(for:colorScheme:)` for timer backgrounds
  - Pass `@Environment(\.colorScheme)` to AttemptColors
- **Dark mode**: Fully supported, never force appearance
- **SF Symbols**: Use for all icons
- **Haptics**: Use `UIImpactFeedbackGenerator` for user feedback

## Data Persistence

- **HistoryManager**: Singleton for session history
- **Storage**: UserDefaults with JSON encoding
- **Usage**: `HistoryManager.shared.addSession(...)`
- **Models**: Use `Codable` for all persisted types

## Common Patterns

### ViewModel with Timer
```swift
private var timerTask: Task<Void, Never>?

private func startTimer() {
    timerTask?.cancel()
    timerTask = Task {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 10_000_000)
            // Update state
        }
    }
}

nonisolated deinit {
    timerTask?.cancel()
}
```

### Side Effect Observation
```swift
.onReceive(viewModel.sideEffect) { effect in
    switch effect {
    case .navigateToResults(let target, let attempts):
        navigationPath.append(.results(targetSeconds: target, attempts: attempts))
    }
}
```

### Color Scheme Passing
```swift
@Environment(\.colorScheme) private var colorScheme

// Later in body:
AttemptColors.color(for: index, colorScheme: colorScheme)
```

## Anti-Patterns (NEVER DO)

- ❌ Force unwrapping (`!`) except for SwiftUI property wrappers
- ❌ `as any`, `@ts-ignore` style comments (this is Swift, not TS)
- ❌ Empty catch blocks
- ❌ Direct state mutation (use `updateState { }`)
- ❌ Business logic in Views
- ❌ Breaking MVI unidirectional flow
- ❌ Using GCD when async/await is available
- ❌ Forgetting to cancel Tasks in deinit
- ❌ Hardcoded strings (use Localizable.xcstrings)
