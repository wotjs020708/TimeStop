//
//  MVIProtocols.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI
import Combine

// MARK: - MVI Base Protocols

protocol ViewState: Equatable {}

protocol ViewIntent {}

protocol ViewSideEffect {}

@MainActor
class ViewModel<State: ViewState, Intent: ViewIntent, SideEffect: ViewSideEffect>: ObservableObject {
    @Published private(set) var state: State

    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    var sideEffect: AnyPublisher<SideEffect, Never> {
        sideEffectSubject.eraseToAnyPublisher()
    }

    init(initialState: State) {
        self.state = initialState
    }

    nonisolated deinit {}

    func send(_ intent: Intent) {
        fatalError("send(_:) must be overridden")
    }

    func updateState(_ transform: (inout State) -> Void) {
        var newState = state
        transform(&newState)
        state = newState
    }

    func emitSideEffect(_ effect: SideEffect) {
        sideEffectSubject.send(effect)
    }
}
