# TimeSense ⏱️

시간 감각을 테스트하는 iOS 게임 앱

## 📱 소개

**TimeSense**는 당신의 내부 시계가 얼마나 정확한지 테스트하는 간단하지만 중독성 있는 게임입니다.
목표 시간을 설정하고, 화면을 보지 않고 시간이 다 됐다고 생각될 때 멈춰보세요!

## 🎮 플레이 방법

1. 목표 시간 선택 (1-60초)
2. 탭하여 시작 — 화면 색상이 변합니다
3. 머릿속으로 세고 시간이 됐다고 생각되면 탭
4. 얼마나 정확했는지 확인하세요!

## ✨ 기능

- ⏱️ 밀리초 단위 정밀 측정
- 🎯 세션당 여러 번 시도 가능
- 🎨 시도별 색상 구분 결과
- 📊 모든 세션 기록 저장
- 🌍 영어/한국어 지원
- 🚫 광고 없음, 인앱 구매 없음

## 🛠️ 기술 스택

- **SwiftUI** - UI 프레임워크
- **MVI Architecture** - 상태 관리
- **Combine** - 반응형 프로그래밍
- **iOS 17.0+** 지원

## 📁 프로젝트 구조

```
TimeStop/
├── Core/                # 핵심 유틸리티
│   ├── MVIProtocols.swift
│   ├── AttemptColors.swift
│   └── HistoryManager.swift
├── Presentation/        # 화면별 View & ViewModel
│   ├── Onboarding/
│   ├── TimeInput/
│   ├── Timer/
│   ├── Results/
│   └── History/
└── Resources/           # 리소스 파일
    └── Localizable.xcstrings
```

## 🚀 빌드 방법

```bash
# Debug 빌드
xcodebuild -project TimeStop.xcodeproj -scheme TimeStop -configuration Debug build

# Release 빌드
xcodebuild -project TimeStop.xcodeproj -scheme TimeStop -configuration Release build
```

## 📄 라이선스

© 2026 Jaesun Eo. All rights reserved.

## 📧 연락처

**Email:** wotjs020708@gmail.com
