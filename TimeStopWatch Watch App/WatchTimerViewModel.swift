//
//  WatchTimerViewModel.swift
//  TimeStopWatch Watch App
//
//  Created by Claude on 1/31/26.
//

import SwiftUI
import Combine

struct WatchTimerState: ViewState {
    var targetSeconds: Int
    var timerState: TimerState = .ready
    var elapsedTime: TimeInterval = 0
    var attempts: [Attempt] = []
}

enum WatchTimerIntent: ViewIntent {
    case startTapped
    case stopTapped
    case resetTapped
}

enum WatchTimerSideEffect: ViewSideEffect {
    case none
}

@MainActor
final class WatchTimerViewModel: ViewModel<WatchTimerState, WatchTimerIntent, WatchTimerSideEffect> {
    private var timerCancellable: AnyCancellable?
    private var startTime: Date?
    
    init(targetSeconds: Int) {
        super.init(initialState: WatchTimerState(targetSeconds: targetSeconds))
    }
    
    override func send(_ intent: WatchTimerIntent) {
        switch intent {
        case .startTapped:
            startTimer()
            
        case .stopTapped:
            stopTimer()
            
        case .resetTapped:
            resetTimer()
        }
    }
    
    private func startTimer() {
        updateState { $0.timerState = .running }
        startTime = Date()
        updateState { state in
            state.elapsedTime = 0
        }
        
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    guard let startTime = self.startTime else { return }
                    let elapsed = Date().timeIntervalSince(startTime)
                    self.updateState { $0.elapsedTime = elapsed }
                    
                    if elapsed > Double(self.state.targetSeconds) + 3.0 {
                        self.autoStopTimer(at: elapsed)
                    }
                }
            }
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()
        
        let finalTime = state.elapsedTime
        
        updateState { state in
            state.timerState = .stopped
        }
        
        let attempt = Attempt(
            id: UUID(),
            targetSeconds: state.targetSeconds,
            actualSeconds: finalTime
        )
        updateState { $0.attempts.append(attempt) }
        
        ConnectivityManager.shared.syncSession(
            targetSeconds: state.targetSeconds,
            attempts: state.attempts
        )
    }
    
    private func autoStopTimer(at elapsed: TimeInterval) {
        timerCancellable?.cancel()
        
        updateState { state in
            state.elapsedTime = elapsed
            state.timerState = .stopped
        }
        
        let attempt = Attempt(
            id: UUID(),
            targetSeconds: state.targetSeconds,
            actualSeconds: elapsed
        )
        updateState { $0.attempts.append(attempt) }
        
        ConnectivityManager.shared.syncSession(
            targetSeconds: state.targetSeconds,
            attempts: state.attempts
        )
    }
    
    private func resetTimer() {
        updateState { state in
            state.timerState = .ready
            state.elapsedTime = 0
        }
        startTime = nil
    }
    
    nonisolated deinit {
        timerCancellable?.cancel()
    }
}
