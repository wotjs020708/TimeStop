# Draft: watchOS 앱 개발

## Requirements (confirmed)
- **앱 범위**: iOS 동기화 포함 (Watch Connectivity 사용)
- **위젯**: 함께 추가 (WidgetKit 컴플리케이션)
- **햅틱**: 플랫폼별 분리 (HapticsProvider 프로토콜)

## Technical Decisions
- **아키텍처**: 기존 MVI 패턴 유지 (MVIProtocols.swift 공유)
- **코드 공유 방식**: Target Membership (프로젝트 규모가 작으므로 Swift Package 대신)
- **동기화 방식**: Watch Connectivity - `transferUserInfo` (세션 기록 보장 전달)
- **위젯 프레임워크**: WidgetKit (ClockKit은 deprecated)

## Research Findings
- watchOS 10+에서 SwiftUI 권장 (WatchKit 레거시)
- `WKInterfaceDevice.current().play(_:)` 사용 (CoreHaptics 없음)
- 타이머는 `Date().timeIntervalSince(startTime)` 방식으로 구현
- `@AppStorage`로 상태 영속성 확보
- 시뮬레이터에서 `transferUserInfo` 미동작 → 실기기 테스트 필요

## Scope Boundaries
### INCLUDE
- watchOS 앱 타겟 생성
- 타이머 기능 (시작/정지/결과)
- iOS ↔ watchOS 세션 동기화
- 위젯/컴플리케이션 (타이머 상태 표시)
- 햅틱 추상화 레이어
- Attempt 모델 Core로 이동

### EXCLUDE
- Apple Watch 전용 결과 분석 화면 (기본 결과만)
- 히스토리 전체 보기 (iOS에서 확인)
- 온보딩 화면 (워치는 즉시 시작)
- 복잡한 통계 (iOS 앱에서 제공)

## Open Questions
- (모두 해결됨)

## Test Strategy Decision
- **Infrastructure exists**: NO (테스트 타겟 없음)
- **User wants tests**: YES (TDD)
- **QA approach**: TDD (RED-GREEN-REFACTOR)
- **Test Framework**: XCTest (Xcode 기본)
- **Test Targets**: TimeStopTests (iOS), TimeStopWatchTests (watchOS)
