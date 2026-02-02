
## LSP vs Build Behavior

SourceKit in Xcode sometimes shows "Cannot find symbol" errors for symbols in the same target even though the build succeeds. This is a known caching issue:
- **Root cause**: SourceKit doesn't index new code in the same target immediately
- **Verification**: Always verify with actual xcodebuild, not just LSP diagnostics
- **Pattern**: NavigationLink and nested ViewModels in watchOS apps work correctly at compile time despite LSP warnings
- **Solution**: Trust the build output over LSP when they conflict

## watchOS NavigationStack Pattern

Successfully implemented watchOS navigation with:
- `NavigationStack` as top-level container
- `NavigationLink` with explicit view initialization
- Pass `@StateObject` ViewModel directly to linked view
- Works with localized strings via `String(localized:)`

## Picker Implementation for watchOS

Used `.pickerStyle(.wheel)` for watchOS Picker:
- Best UX for watch-sized screens
- Requires explicit height frame for proper layout
- ForEach with `id: \.self` for simple Int values
