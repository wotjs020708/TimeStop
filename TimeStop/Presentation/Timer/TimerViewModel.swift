//
//  TimerViewModel.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI
import Combine

enum TimerState: Equatable {
    case ready
    case running
    case stopped
}

struct Attempt: Equatable, Identifiable, Hashable {
    let id: UUID
    let targetSeconds: Int
    let actualSeconds: Double

    var difference: Double {
        actualSeconds - Double(targetSeconds)
    }
}

struct TimerViewState: ViewState {
    var targetSeconds: Int
    var timerState: TimerState = .ready
    var elapsedTime: TimeInterval = 0
    var attempts: [Attempt] = []
    var finishPressProgress: Double = 0
}

enum TimerIntent: ViewIntent {
    case startTapped
    case stopTapped
    case continueTapped
    case finishPressed
    case finishReleased
}

enum TimerSideEffect: ViewSideEffect {
    case navigateToResults(targetSeconds: Int, attempts: [Attempt])
}

@MainActor
final class TimerViewModel: ViewModel<TimerViewState, TimerIntent, TimerSideEffect> {
    private var timerTask: Task<Void, Never>?
    private var finishTask: Task<Void, Never>?
    private var startTime: Date?

    init(targetSeconds: Int) {
        super.init(initialState: TimerViewState(targetSeconds: targetSeconds))
    }

    override func send(_ intent: TimerIntent) {
        switch intent {
        case .startTapped:
            startTimer()

        case .stopTapped:
            stopTimer()

        case .continueTapped:
            resetTimer()

        case .finishPressed:
            startFinishProgress()

        case .finishReleased:
            cancelFinish()
        }
    }

    private func startTimer() {
        updateState { $0.timerState = .running }
        startTime = Date()
        updateState { $0.elapsedTime = 0 }

        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

                guard let startTime = startTime else { return }
                let elapsed = Date().timeIntervalSince(startTime)
                updateState { state in
                    state.elapsedTime = elapsed
                }

                // Auto-stop if elapsed time exceeds target by 3 seconds
                if elapsed > Double(state.targetSeconds) + 3.0 {
                    stopTimer()
                    return
                }
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        updateState { $0.timerState = .stopped }

        let attempt = Attempt(
            id: UUID(),
            targetSeconds: state.targetSeconds,
            actualSeconds: state.elapsedTime
        )
        updateState { $0.attempts.append(attempt) }
    }

    private func resetTimer() {
        updateState { state in
            state.timerState = .ready
            state.elapsedTime = 0
        }
        startTime = nil
    }

    private func startFinishProgress() {
        updateState { $0.finishPressProgress = 0 }

        finishTask?.cancel()
        finishTask = Task {
            let duration: TimeInterval = 1.5
            let steps = 30

            for step in 0...steps {
                guard !Task.isCancelled else { return }

                updateState { state in
                    state.finishPressProgress = Double(step) / Double(steps)
                }

                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000 / Double(steps)))
            }

            guard !Task.isCancelled else { return }
            finishSession()
        }
    }

    private func cancelFinish() {
        finishTask?.cancel()
        updateState { $0.finishPressProgress = 0 }
    }

    private func finishSession() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)

        emitSideEffect(.navigateToResults(
            targetSeconds: state.targetSeconds,
            attempts: state.attempts
        ))
    }

    nonisolated deinit {
        timerTask?.cancel()
        finishTask?.cancel()
    }
}
