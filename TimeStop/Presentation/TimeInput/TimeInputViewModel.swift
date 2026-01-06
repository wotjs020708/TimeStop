//
//  TimeInputViewModel.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI

struct TimeInputState: ViewState {
    var targetSeconds: Int = 10

    var isValid: Bool {
        targetSeconds >= 1 && targetSeconds <= 60
    }
}

enum TimeInputIntent: ViewIntent {
    case sliderChanged(Int)
    case startTapped
}

enum TimeInputSideEffect: ViewSideEffect {
    case navigateToTimer(targetSeconds: Int)
    case triggerHaptic
}

@MainActor
final class TimeInputViewModel: ViewModel<TimeInputState, TimeInputIntent, TimeInputSideEffect> {
    init() {
        super.init(initialState: TimeInputState())
    }

    override func send(_ intent: TimeInputIntent) {
        switch intent {
        case .sliderChanged(let seconds):
            updateState { $0.targetSeconds = seconds }
            emitSideEffect(.triggerHaptic)

        case .startTapped:
            guard state.isValid else { return }
            emitSideEffect(.navigateToTimer(targetSeconds: state.targetSeconds))
        }
    }
}
