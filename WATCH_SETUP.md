# Apple Watch App Setup Guide

## Overview
이 가이드는 TimeStop iOS 앱에 Apple Watch 앱을 추가하는 방법을 설명합니다.

## Prerequisites
- Xcode 26.2+
- iOS 17.0+, watchOS 10.0+
- Apple Developer Account (실제 디바이스 테스트용)

## Step 1: Xcode에서 watchOS Target 추가

1. Xcode에서 `TimeStop.xcodeproj` 열기
2. **File → New → Target**
3. **watchOS → Watch App** 선택
4. 다음 설정 입력:
   - Product Name: `TimeStopWatch`
   - Bundle Identifier: `com.jaesuneo.TimeStop.watchkitapp`
   - Minimum watchOS Version: `10.0`
   - Include Notification Scene: ❌ (체크 해제)
5. **Finish** 클릭

## Step 2: 파일을 타겟에 추가

### 공유 파일 (iOS + watchOS 모두)
다음 파일들을 선택하고 File Inspector에서 **Target Membership** 체크:

1. **Core/MVIProtocols.swift**
   - ✅ TimeStop (iOS)
   - ✅ TimeStopWatch Watch App (watchOS)

2. **Core/ConnectivityManager.swift**
   - ✅ TimeStop (iOS)
   - ✅ TimeStopWatch Watch App (watchOS)

3. **Presentation/Timer/TimerViewModel.swift**
   - ✅ TimeStop (iOS)
   - ✅ TimeStopWatch Watch App (watchOS)
   - 이 파일에 포함된 `Attempt`, `TimerState` 타입이 watchOS에서 필요

### watchOS 전용 파일
다음 파일들은 **watchOS만** 체크:

1. **TimeStopWatch Watch App/TimeStopWatchApp.swift**
   - ✅ TimeStopWatch Watch App

2. **TimeStopWatch Watch App/WatchTimerViewModel.swift**
   - ✅ TimeStopWatch Watch App

3. **TimeStopWatch Watch App/WatchTimerScreen.swift**
   - ✅ TimeStopWatch Watch App

## Step 3: Capabilities 설정

### iOS Target (TimeStop)
1. Project Navigator에서 프로젝트 선택
2. **TARGETS → TimeStop** 선택
3. **Signing & Capabilities** 탭
4. Team 선택 (NZJWJ35U9D)

### watchOS Target (TimeStopWatch Watch App)
1. **TARGETS → TimeStopWatch Watch App** 선택
2. **Signing & Capabilities** 탭
3. **동일한 Team** 선택 (NZJWJ35U9D)

## Step 4: Build Settings 확인

### watchOS Target Build Settings
다음 설정이 올바른지 확인:

```
PRODUCT_NAME = TimeStopWatch Watch App
PRODUCT_BUNDLE_IDENTIFIER = com.jaesuneo.TimeStop.watchkitapp
TARGETED_DEVICE_FAMILY = 4 (Watch)
WATCHOS_DEPLOYMENT_TARGET = 10.0
SWIFT_VERSION = 5.0
```

## Step 5: 빌드 및 테스트

### Simulator에서 빌드
```bash
# watchOS 앱 빌드
xcodebuild -project TimeStop.xcodeproj \
  -scheme TimeStopWatch \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  build

# iOS 앱 빌드 (확인용)
xcodebuild -project TimeStop.xcodeproj \
  -scheme TimeStop \
  -configuration Debug \
  build
```

### Xcode에서 실행
1. Scheme 선택: **TimeStopWatch Watch App**
2. Destination 선택: **Apple Watch Series 9 (45mm)** (또는 다른 시뮬레이터)
3. **⌘ + R** 실행

## Step 6: Watch Connectivity 테스트

### iOS 앱 실행
1. Scheme을 **TimeStop**으로 변경
2. iPhone 시뮬레이터 선택
3. 실행

### Watch 앱 실행
1. Scheme을 **TimeStopWatch Watch App**으로 변경
2. **동일한 iPhone과 페어링된 Watch 시뮬레이터** 선택
3. 실행

### 통신 테스트
1. Watch 앱에서 타이머 시작
2. Stop 버튼으로 시도 기록
3. iOS 앱의 History 탭에서 동기화 확인 (수동 새로고침 필요할 수 있음)

## Known Issues & Solutions

### Issue: "No such module 'WatchConnectivity'"
**Solution:** watchOS 타겟이 올바르게 설정되지 않음. Step 1 다시 확인.

### Issue: "Cannot find type 'ViewState' in scope"
**Solution:** `MVIProtocols.swift`가 watchOS 타겟에 추가되지 않음. Step 2 확인.

### Issue: "Cannot find type 'Attempt' in scope"
**Solution:** `TimerViewModel.swift`가 watchOS 타겟에 추가되지 않음. Step 2 확인.

### Issue: Simulator에서 transferUserInfo 작동 안 함
**Solution:** 정상 동작. `transferUserInfo`는 실제 디바이스에서만 작동. Simulator에서는 `updateApplicationContext` 사용.

## Architecture Notes

### MVI Pattern
watchOS 앱은 iOS 앱과 동일한 MVI 패턴 사용:
- **State:** `WatchTimerState` (ViewState 준수)
- **Intent:** `WatchTimerIntent` (ViewIntent 준수)
- **ViewModel:** `WatchTimerViewModel` (ViewModel 상속)

### Data Sync Strategy
- **방법:** `updateApplicationContext` (최신 상태 동기화)
- **시점:** Watch에서 Stop 버튼 누를 때
- **데이터:** `SessionData` (targetSeconds, attempts, timestamp)
- **방향:** Watch → iOS (단방향)

### Shared Models
- `Attempt` - UI 모델 (iOS/watchOS 공유)
- `TimerState` - 타이머 상태 enum (iOS/watchOS 공유)
- `SessionData` - Watch Connectivity 전송용 (Codable)
- `AttemptData` - Codable version of Attempt

## Next Steps

1. ✅ watchOS 타겟 추가 완료
2. ⬜ iOS 앱에 Watch 연동 UI 추가 (선택사항)
3. ⬜ HistoryManager에 Watch 데이터 수신 처리 추가
4. ⬜ 로컬라이제이션 추가 (EN/KO)
5. ⬜ App Icon 추가
6. ⬜ 실제 디바이스에서 테스트

## References

- [Apple Watch Programming Guide](https://developer.apple.com/documentation/watchos-apps)
- [Watch Connectivity Framework](https://developer.apple.com/documentation/watchconnectivity)
- [SwiftUI for watchOS](https://developer.apple.com/documentation/swiftui/building-apps-for-watchos)
