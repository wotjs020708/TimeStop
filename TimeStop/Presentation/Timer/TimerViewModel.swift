//
//  TimerViewModel.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI
import Combine

struct TimerViewState: ViewState {
    var targetSeconds: Int
    var timerState: TimerState = .ready
    var elapsedTime: TimeInterval = 0
    var lastDisplayedTime: TimeInterval = 0  // The exact time shown on screen when stopped
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
    case playHaptic(NotificationType)
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
        updateState { state in
            state.elapsedTime = 0
            state.lastDisplayedTime = 0
        }

        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

                guard let startTime = startTime else { return }
                let elapsed = Date().timeIntervalSince(startTime)
                updateState { state in
                    state.elapsedTime = elapsed
                    state.lastDisplayedTime = elapsed  // Save exact displayed time
                }

                // Auto-stop if elapsed time exceeds target by 3 seconds
                if elapsed > Double(state.targetSeconds) + 3.0 {
                    // For auto-stop, use the current elapsed time
                    autoStopTimer(at: elapsed)
                    return
                }
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()

        // Use lastDisplayedTime - this is the EXACT time that was shown on screen
        let finalTime = state.lastDisplayedTime

        updateState { state in
            state.elapsedTime = finalTime  // Keep display consistent
            state.timerState = .stopped
        }

        let attempt = Attempt(
            id: UUID(),
            targetSeconds: state.targetSeconds,
            actualSeconds: finalTime
        )
        updateState { $0.attempts.append(attempt) }
    }

    private func autoStopTimer(at elapsed: TimeInterval) {
        timerTask?.cancel()

        updateState { state in
            state.elapsedTime = elapsed
            state.lastDisplayedTime = elapsed
            state.timerState = .stopped
        }

        let attempt = Attempt(
            id: UUID(),
            targetSeconds: state.targetSeconds,
            actualSeconds: elapsed
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
        emitSideEffect(.playHaptic(.success))

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
