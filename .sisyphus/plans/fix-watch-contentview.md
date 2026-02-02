# watchOS ContentView 수정

## TL;DR

> **Quick Summary**: watchOS 앱의 ContentView가 placeholder 상태라 실제 타이머 화면으로 연결 필요
> 
> **Deliverables**:
> - ContentView.swift 수정 (Hello World → 타이머 시작 화면)
> 
> **Estimated Effort**: Quick (5분)
> **Parallel Execution**: NO

---

## Context

### 문제
- `TimeStopWatch Watch App/ContentView.swift`가 "Hello, world!" placeholder 상태
- `WatchTimerScreen`, `WatchTimerViewModel`은 이미 구현되어 있음
- 하지만 앱 진입점(`TimeStopWatchApp.swift`)이 ContentView를 보여주고 있어서 연결이 안 됨

### 원인
- 이전 작업에서 타이머 화면은 만들었지만 ContentView 업데이트를 누락함

---

## TODOs

- [x] 1. ContentView.swift 수정

  **What to do**:
  - "Hello, world!" 코드 제거
  - 목표 시간 선택 Picker 추가 (5, 10, 15, 20, 30, 45, 60초)
  - NavigationStack으로 WatchTimerScreen 연결
  - 시작 버튼 추가

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: `[]`

  **References**:
  - `TimeStopWatch Watch App/WatchTimerScreen.swift` - 타이머 화면
  - `TimeStopWatch Watch App/WatchTimerViewModel.swift` - 뷰모델 (targetSeconds 파라미터 필요)
  - `TimeStop/Presentation/TimeInput/TimeInputScreen.swift` - iOS 시간 선택 화면 참고

  **Acceptance Criteria**:
  - [ ] watchOS 시뮬레이터에서 앱 실행 시 시간 선택 화면 표시
  - [ ] 시간 선택 후 시작 버튼 탭 → 타이머 화면으로 이동
  - [ ] 타이머 시작/정지/리셋 동작 확인
  - [ ] 빌드 성공: `xcodebuild -scheme "TimeStopWatch Watch App" build`

  **Commit**: YES
  - Message: `fix(watch): connect ContentView to WatchTimerScreen`
  - Files: `TimeStopWatch Watch App/ContentView.swift`

---

## 수정할 코드

### Before (현재)
```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}
```

### After (수정 후)
```swift
struct ContentView: View {
    @State private var targetSeconds: Int = 10
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(String(localized: "watch_select_time"))
                    .font(.headline)
                
                Picker(String(localized: "watch_seconds"), selection: $targetSeconds) {
                    ForEach([5, 10, 15, 20, 30, 45, 60], id: \.self) { seconds in
                        Text("\(seconds)s").tag(seconds)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 80)
                
                NavigationLink {
                    WatchTimerScreen(viewModel: WatchTimerViewModel(targetSeconds: targetSeconds))
                } label: {
                    Label(String(localized: "start"), systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("TimeSense")
        }
    }
}
```

---

## Success Criteria

```bash
# watchOS 빌드
xcodebuild -scheme "TimeStopWatch Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build
# Expected: BUILD SUCCEEDED

# 시뮬레이터에서 확인
# 1. 앱 실행 → 시간 선택 화면 표시
# 2. 시간 선택 → 시작 버튼 탭 → 타이머 화면
# 3. 타이머 시작/정지 동작 확인
```
