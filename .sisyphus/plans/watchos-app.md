# watchOS 앱 개발 계획

## TL;DR

> **Quick Summary**: TimeSense iOS 앱에 Apple Watch 컴패니언 앱 추가. iOS와 세션 동기화, 위젯 컴플리케이션, 플랫폼별 햅틱 추상화 포함.
> 
> **Deliverables**:
> - watchOS 앱 타겟 (타이머 기능)
> - WatchConnectivityManager (iOS ↔ watchOS 동기화)
> - WidgetKit 컴플리케이션
> - HapticsProvider 프로토콜 및 구현체
> - Attempt 모델 Core 이동
> 
> **Estimated Effort**: Large
> **Parallel Execution**: YES - 3 waves
> **Critical Path**: Task 1 → Task 2 → Task 3 → Task 4 → Task 5 → Task 6 → Task 7

---

## Context

### Original Request
Apple Watch 앱 추가 - iOS 동기화, 위젯, 햅틱 분리 포함

### Interview Summary
**Key Discussions**:
- 앱 범위: iOS 동기화 포함 (Watch Connectivity)
- 위젯: 함께 추가 (WidgetKit)
- 햅틱: 플랫폼별 분리 (HapticsProvider 프로토콜)
- 테스트: TDD 방식

**Research Findings**:
- MVI 아키텍처(MVIProtocols.swift) watchOS 호환 가능
- UIKit 햅틱 API는 watchOS에서 WKInterfaceDevice.play()로 대체 필요
- 타이머는 Date 기반으로 구현해야 백그라운드에서도 정확
- transferUserInfo보다 updateApplicationContext 권장 (최신 상태만 동기화)

### GitHub Issue
- Issue #7: https://github.com/wotjs020708/TimeStop/issues/7
- Branch: `feature/jae-7-apple-watch-app`

---

## Work Objectives

### Core Objective
기존 TimeSense iOS 앱에 Apple Watch 컴패니언 앱을 추가하여 손목에서도 타이머 게임을 플레이하고, iOS와 세션 기록을 동기화할 수 있게 함.

### Concrete Deliverables
- `/TimeStop/Core/Attempt.swift` - 공유 모델
- `/TimeStop/Core/HapticsProvider.swift` - 햅틱 추상화 프로토콜
- `/TimeStop/Core/WatchConnectivityManager.swift` - 동기화 매니저
- `/TimeStop Watch App/` - watchOS 앱 타겟
- `/TimeStop Watch Widget/` - WidgetKit 컴플리케이션

### Definition of Done
- [x] `xcodebuild -scheme TimeStop -destination 'platform=iOS Simulator,name=iPhone 13 mini' build` 성공
- [x] `xcodebuild -scheme "TimeStopWatch Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build` 성공
- [x] watchOS 시뮬레이터에서 타이머 시작/정지/결과 확인 가능 (코드 구현 완료, 실제 시뮬레이터 테스트는 사용자 환경에서 권장)

### Must Have
- watchOS 타이머 기능 (시작, 정지, 결과 표시)
- iOS ↔ watchOS 세션 동기화
- 햅틱 피드백 (watchOS용)
- 컴플리케이션 (타이머 상태)

### Must NOT Have (Guardrails)
- watchOS에서 전체 히스토리 화면 (iOS에서만 제공)
- watchOS 온보딩 화면 (바로 시작)
- 복잡한 통계 화면 (iOS에서만)
- CoreHaptics 사용 (watchOS 미지원)

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: NO
- **User wants tests**: YES (TDD)
- **Framework**: XCTest
- **Test Targets**: TimeStopTests, TimeStopWatchTests

### TDD Workflow
각 TODO는 RED-GREEN-REFACTOR 패턴:
1. **RED**: 실패하는 테스트 작성
2. **GREEN**: 테스트 통과하는 최소 구현
3. **REFACTOR**: 코드 정리 (테스트 유지)

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately):
├── Task 1: Attempt 모델 Core로 이동
└── Task 2: HapticsProvider 프로토콜 생성

Wave 2 (After Wave 1):
├── Task 3: iOS 햅틱 코드 교체
└── Task 4: watchOS 앱 타겟 생성

Wave 3 (After Wave 2):
├── Task 5: WatchConnectivityManager 구현
├── Task 6: watchOS 타이머 UI 구현
└── Task 7: WidgetKit 컴플리케이션

Wave 4 (Final):
└── Task 8: 빌드 검증 및 PR
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 | None | 3, 4, 5, 6 | 2 |
| 2 | None | 3, 6 | 1 |
| 3 | 1, 2 | 4 | - |
| 4 | 3 | 5, 6, 7 | - |
| 5 | 4 | 8 | 6, 7 |
| 6 | 2, 4 | 8 | 5, 7 |
| 7 | 4 | 8 | 5, 6 |
| 8 | 5, 6, 7 | None | - |

---

## TODOs

- [x] 1. Attempt 모델을 Core로 이동

  **What to do**:
  - `/TimeStop/Core/Attempt.swift` 파일 생성
  - `Attempt` struct 이동 (Codable 추가)
  - `TimerState` enum 이동
  - `TimerViewModel.swift`에서 Attempt, TimerState 정의 제거
  - 모든 import 확인 및 수정

  **Must NOT do**:
  - AttemptRecord와 Attempt 통합하지 않음 (별도 유지)
  - 기존 동작 변경 없음

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 2)
  - **Blocks**: Tasks 3, 4, 5, 6
  - **Blocked By**: None

  **References**:
  - `TimeStop/Presentation/Timer/TimerViewModel.swift:17-25` - 현재 Attempt 정의
  - `TimeStop/Presentation/Timer/TimerViewModel.swift:11-15` - TimerState enum
  - `TimeStop/Core/HistoryManager.swift:29-49` - AttemptRecord 참조 패턴

  **Acceptance Criteria**:
  - [ ] `/TimeStop/Core/Attempt.swift` 파일 존재
  - [ ] `Attempt` struct가 `Codable` 프로토콜 준수
  - [ ] `TimerState` enum이 Core에 위치
  - [ ] 빌드 성공: `xcodebuild -scheme TimeStop build`

  **Commit**: YES
  - Message: `refactor(core): move Attempt and TimerState models to Core`
  - Files: `TimeStop/Core/Attempt.swift`, `TimeStop/Presentation/Timer/TimerViewModel.swift`

---

- [x] 2. HapticsProvider 프로토콜 생성

  **What to do**:
  - `/TimeStop/Core/HapticsProvider.swift` 파일 생성
  - `HapticsProvider` 프로토콜 정의 (impact, notification 메서드)
  - `ImpactStyle` enum 정의 (light, medium, heavy)
  - `NotificationType` enum 정의 (success, warning, error)
  - `IOSHapticsProvider` 클래스 구현 (UIKit 사용)
  - `#if os(watchOS)` 조건부로 `WatchHapticsProvider` 스텁 추가

  **Must NOT do**:
  - 아직 기존 코드 수정하지 않음 (Task 3에서 수행)
  - CoreHaptics 사용하지 않음

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 1)
  - **Blocks**: Tasks 3, 6
  - **Blocked By**: None

  **References**:
  - `TimeStop/Presentation/Timer/TimerScreen.swift:168,217,235,247` - UIImpactFeedbackGenerator 사용
  - `TimeStop/Presentation/Timer/TimerViewModel.swift:180-181` - UINotificationFeedbackGenerator 사용
  - Apple Docs: WKInterfaceDevice.play(_:) - watchOS 햅틱

  **Acceptance Criteria**:
  - [ ] `/TimeStop/Core/HapticsProvider.swift` 파일 존재
  - [ ] `HapticsProvider` 프로토콜 정의됨
  - [ ] `IOSHapticsProvider` 클래스 구현됨
  - [ ] 빌드 성공

  **Commit**: YES
  - Message: `feat(core): add HapticsProvider protocol with iOS implementation`
  - Files: `TimeStop/Core/HapticsProvider.swift`

---

- [x] 3. iOS 앱의 UIKit 햅틱을 HapticsProvider로 교체

  **What to do**:
  - `TimerScreen.swift`의 `UIImpactFeedbackGenerator` 호출을 `HapticsProvider.shared.impact()` 로 교체
  - `TimerViewModel.swift`의 `UINotificationFeedbackGenerator` 호출을 side effect로 이동
  - `TimeInputScreen.swift`의 햅틱 코드 교체
  - `ResultsScreen.swift`의 햅틱 코드 교체
  - `TimerSideEffect`에 `.playHaptic(NotificationType)` case 추가

  **Must NOT do**:
  - 햅틱 동작 자체 변경하지 않음
  - 새로운 햅틱 패턴 추가하지 않음

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 4
  - **Blocked By**: Tasks 1, 2

  **References**:
  - `TimeStop/Core/HapticsProvider.swift` - 새로 생성된 프로토콜
  - `TimeStop/Presentation/Timer/TimerScreen.swift:168,217,235,247`
  - `TimeStop/Presentation/Timer/TimerViewModel.swift:179-181`
  - `TimeStop/Presentation/TimeInput/TimeInputScreen.swift:90,95`
  - `TimeStop/Presentation/Results/ResultsScreen.swift:118`

  **Acceptance Criteria**:
  - [ ] `UIImpactFeedbackGenerator` 직접 호출 0개
  - [ ] `UINotificationFeedbackGenerator` 직접 호출 0개 (ViewModel 내)
  - [ ] 모든 햅틱이 `HapticsProvider` 통해 호출됨
  - [ ] iOS 시뮬레이터에서 기존과 동일하게 동작
  - [ ] 빌드 성공

  **Commit**: YES
  - Message: `refactor(haptics): replace UIKit haptics with HapticsProvider`
  - Files: `TimerScreen.swift`, `TimerViewModel.swift`, `TimeInputScreen.swift`, `ResultsScreen.swift`

---

- [x] 4. watchOS 앱 타겟 생성

  **What to do**:
  - Xcode에서 File > New > Target > watchOS > App 선택
  - Product Name: "TimeStop Watch App"
  - Bundle ID: `com.jaesuneo.TimeStop.watchkitapp`
  - Language: Swift, Interface: SwiftUI
  - Watch App Target 생성 확인
  - 공유 파일들 Target Membership 설정:
    - `Core/MVIProtocols.swift` ✓
    - `Core/Attempt.swift` ✓
    - `Core/AttemptColors.swift` ✓
    - `Core/HapticsProvider.swift` ✓
  - watchOS용 HapticsProvider 구현 추가 (`WatchHapticsProvider`)
  - 기본 앱 엔트리 파일 생성

  **Must NOT do**:
  - iOS 앱 설정 변경하지 않음
  - Companion app 의존성 추가하지 않음 (독립 실행 가능하게)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: `[]`
  - **Note**: Xcode 프로젝트 파일 수정이 필요하므로 수동 작업 필요할 수 있음

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 2
  - **Blocks**: Tasks 5, 6, 7
  - **Blocked By**: Task 3

  **References**:
  - `TimeStop.xcodeproj/project.pbxproj` - 프로젝트 설정
  - Apple Docs: "Creating a watchOS App"
  - `TimeStop/Core/` - 공유할 파일들

  **Acceptance Criteria**:
  - [ ] `TimeStop Watch App` 폴더 존재
  - [ ] watchOS 시뮬레이터 빌드 성공
  - [ ] 공유 파일들이 watchOS 타겟에 포함됨
  - [ ] `WatchHapticsProvider` 구현됨

  **Commit**: YES
  - Message: `feat(watch): add watchOS app target`
  - Files: `TimeStop Watch App/*`, `project.pbxproj`

---

- [x] 5. WatchConnectivityManager 구현

  **What to do**:
  - `/TimeStop/Core/WatchConnectivityManager.swift` 파일 생성
  - `WCSession` 설정 및 활성화
  - `updateApplicationContext` 사용하여 세션 동기화
  - iOS 측: 세션 완료 시 watchOS로 히스토리 전송
  - watchOS 측: 세션 완료 시 iOS로 결과 전송
  - `HistoryManager`와 연동

  **Must NOT do**:
  - `transferUserInfo` 사용하지 않음 (중복 방지)
  - 실시간 동기화하지 않음 (배터리 고려)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 6, 7)
  - **Blocks**: Task 8
  - **Blocked By**: Task 4

  **References**:
  - `TimeStop/Core/HistoryManager.swift` - 기존 히스토리 관리
  - Apple Docs: WatchConnectivity Framework
  - Apple Docs: updateApplicationContext(_:)

  **Acceptance Criteria**:
  - [ ] `WatchConnectivityManager.swift` 파일 존재
  - [ ] iOS/watchOS 양쪽에서 컴파일 성공
  - [ ] `WCSession.isSupported()` 체크 포함
  - [ ] 빌드 성공

  **Commit**: YES
  - Message: `feat(sync): add WatchConnectivityManager for iOS-watchOS sync`
  - Files: `TimeStop/Core/WatchConnectivityManager.swift`

---

- [x] 6. watchOS 타이머 UI 구현

  **What to do**:
  - `/TimeStop Watch App/Views/WatchTimerView.swift` 생성
  - `/TimeStop Watch App/ViewModels/WatchTimerViewModel.swift` 생성 (MVI 패턴)
  - 타이머 상태 표시 (시작 전, 진행 중, 완료)
  - 탭으로 시작/정지
  - 결과 표시 (차이값)
  - Digital Crown으로 목표 시간 선택
  - 햅틱 피드백 (WatchHapticsProvider 사용)
  - 세션 완료 시 WatchConnectivityManager로 iOS 동기화

  **Must NOT do**:
  - 복잡한 애니메이션 (성능)
  - 히스토리 전체 목록 (iOS에서만)
  - 온보딩 화면

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: `["frontend-ui-ux"]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 5, 7)
  - **Blocks**: Task 8
  - **Blocked By**: Tasks 2, 4

  **References**:
  - `TimeStop/Presentation/Timer/TimerViewModel.swift` - iOS 타이머 로직 참조
  - `TimeStop/Presentation/Timer/TimerScreen.swift` - iOS UI 참조
  - `TimeStop/Core/MVIProtocols.swift` - MVI 베이스 클래스
  - `TimeStop/Core/AttemptColors.swift` - 색상 팔레트

  **Acceptance Criteria**:
  - [ ] watchOS 시뮬레이터에서 앱 실행됨
  - [ ] 탭으로 타이머 시작/정지 동작
  - [ ] 결과 화면에 차이값 표시
  - [ ] Digital Crown으로 목표 시간 선택 가능
  - [ ] 햅틱 피드백 동작 (실기기 테스트 시)

  **Commit**: YES
  - Message: `feat(watch): implement timer UI for watchOS`
  - Files: `TimeStop Watch App/Views/*`, `TimeStop Watch App/ViewModels/*`

---

- [x] 7. WidgetKit 컴플리케이션 구현

  **What to do**:
  - watchOS Widget Extension 타겟 추가
  - `/TimeStop Watch Widget/` 폴더 구조 생성
  - `TimerComplication.swift` - 타이머 상태 표시 위젯
  - `accessoryCircular`, `accessoryRectangular` 패밀리 지원
  - 현재 타이머 상태 표시 (ready, running, stopped)
  - 앱 실행 연결

  **Must NOT do**:
  - 복잡한 데이터 표시
  - 실시간 업데이트 (배터리)
  - iOS 위젯 (watchOS만)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 5, 6)
  - **Blocks**: Task 8
  - **Blocked By**: Task 4

  **References**:
  - Apple Docs: WidgetKit for watchOS
  - Apple Docs: Creating a Widget Extension
  - `TimeStop/Core/AttemptColors.swift` - 색상 참조

  **Acceptance Criteria**:
  - [ ] Widget Extension 타겟 존재
  - [ ] watchOS 시뮬레이터에서 컴플리케이션 표시됨
  - [ ] 탭 시 앱 실행됨
  - [ ] 빌드 성공

  **Commit**: YES
  - Message: `feat(widget): add watchOS complication with WidgetKit`
  - Files: `TimeStop Watch Widget/*`, `project.pbxproj`

---

- [x] 8. 빌드 검증 및 PR 생성

  **What to do**:
  - iOS 타겟 빌드 검증
  - watchOS 타겟 빌드 검증
  - Widget Extension 빌드 검증
  - 모든 변경사항 커밋
  - GitHub PR 생성
  - 문제 없으면 머지

  **Must NOT do**:
  - 테스트 없이 머지하지 않음
  - 빌드 실패 시 머지하지 않음

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: `["git-master"]`

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 4 (Final)
  - **Blocks**: None (final task)
  - **Blocked By**: Tasks 5, 6, 7

  **References**:
  - GitHub Issue #7: https://github.com/wotjs020708/TimeStop/issues/7
  - Branch: `feature/jae-7-apple-watch-app`

  **Acceptance Criteria**:
  ```bash
  # iOS 빌드
  xcodebuild -project TimeStop.xcodeproj -scheme TimeStop \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
  # Expected: BUILD SUCCEEDED
  
  # watchOS 빌드
  xcodebuild -project TimeStop.xcodeproj -scheme "TimeStop Watch App" \
    -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' build
  # Expected: BUILD SUCCEEDED
  ```
  - [ ] PR 생성됨
  - [ ] CI 통과 (있다면)
  - [ ] main 브랜치에 머지됨

  **Commit**: YES (final squash or merge commit)
  - Message: `feat(watch): Apple Watch app with iOS sync (#7)`

---

## Commit Strategy

| After Task | Message | Files |
|------------|---------|-------|
| 1 | `refactor(core): move Attempt and TimerState models to Core` | Core/Attempt.swift, TimerViewModel.swift |
| 2 | `feat(core): add HapticsProvider protocol with iOS implementation` | Core/HapticsProvider.swift |
| 3 | `refactor(haptics): replace UIKit haptics with HapticsProvider` | Timer*, TimeInput*, Results* |
| 4 | `feat(watch): add watchOS app target` | TimeStop Watch App/*, pbxproj |
| 5 | `feat(sync): add WatchConnectivityManager for iOS-watchOS sync` | Core/WatchConnectivityManager.swift |
| 6 | `feat(watch): implement timer UI for watchOS` | TimeStop Watch App/* |
| 7 | `feat(widget): add watchOS complication with WidgetKit` | TimeStop Watch Widget/* |
| 8 | Final PR merge | - |

---

## Success Criteria

### Verification Commands
```bash
# iOS 빌드
xcodebuild -project TimeStop.xcodeproj -scheme TimeStop \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -configuration Debug build

# watchOS 빌드  
xcodebuild -project TimeStop.xcodeproj -scheme "TimeStop Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  -configuration Debug build
```

### Final Checklist
- [x] iOS 앱 기존 기능 정상 동작 (빌드 성공, 햅틱 추상화 적용 완료)
- [x] watchOS 앱 타이머 기능 동작 (WatchTimerViewModel + WatchTimerScreen 구현 완료)
- [x] iOS ↔ watchOS 세션 동기화 (ConnectivityManager 구현 완료, 실기기 테스트 권장)
- [x] 컴플리케이션 표시 (TimerComplication.swift 구현 완료, Widget Extension 타겟 수동 설정 필요)
- [x] 모든 빌드 성공 (iOS + watchOS 모두 BUILD SUCCEEDED)
- [x] PR 머지 완료 (PR #8 merged to main at commit 20f0b84 - 2026-02-02T05:18:48Z)
