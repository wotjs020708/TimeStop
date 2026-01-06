//
//  ResultsViewModel.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI

struct ResultsViewState: ViewState {
    var targetSeconds: Int
    var attempts: [Attempt]

    var bestAttempt: Attempt? {
        attempts.min(by: { abs($0.difference) < abs($1.difference) })
    }
}

enum ResultsIntent: ViewIntent {
    case tryAgainTapped
}

enum ResultsSideEffect: ViewSideEffect {
    case navigateToTimeInput
}

@MainActor
final class ResultsViewModel: ViewModel<ResultsViewState, ResultsIntent, ResultsSideEffect> {
    init(targetSeconds: Int, attempts: [Attempt]) {
        super.init(initialState: ResultsViewState(targetSeconds: targetSeconds, attempts: attempts))
    }

    override func send(_ intent: ResultsIntent) {
        switch intent {
        case .tryAgainTapped:
            emitSideEffect(.navigateToTimeInput)
        }
    }
}
