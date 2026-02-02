# Issues

## [2026-02-02T04:17] UIKit Haptics on watchOS
- **Problem**: TimerViewModel.swift:180 - UINotificationFeedbackGenerator unavailable in watchOS
- **Impact**: watchOS 빌드 실패
- **Solution**: Task 2-3 진행 (HapticsProvider 생성 및 적용)

## [2026-02-02T04:55] Project Structure Corruption Detected
- pbxproj missing references to ~25+ Swift files
- Only TimerViewModel.swift in Sources build phase
- Likely caused by previous watchOS target setup
- Blocking all further work - must fix before Task 3 verification
