//
//  OnboardingViewModel.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI

struct OnboardingState: ViewState {
    var displayedText: String = ""
    var isAnimationComplete: Bool = false
}

enum OnboardingIntent: ViewIntent {
    case onAppear
    case getStartedTapped
}

enum OnboardingSideEffect: ViewSideEffect {
    case navigateToTimeInput
}

@MainActor
final class OnboardingViewModel: ViewModel<OnboardingState, OnboardingIntent, OnboardingSideEffect> {
    private var typingTask: Task<Void, Never>?

    init() {
        super.init(initialState: OnboardingState())
    }

    override func send(_ intent: OnboardingIntent) {
        switch intent {
        case .onAppear:
            startTypingAnimation()

        case .getStartedTapped:
            emitSideEffect(.navigateToTimeInput)
        }
    }

    private func startTypingAnimation() {
        updateState { $0.displayedText = "" }
        updateState { $0.isAnimationComplete = false }

        typingTask?.cancel()
        typingTask = Task {
            let fullText = String(localized: "onboarding_description")

            for char in fullText {
                guard !Task.isCancelled else { return }

                updateState { state in
                    state.displayedText.append(char)
                }

                try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
            }

            updateState { $0.isAnimationComplete = true }
        }
    }

    nonisolated deinit {
        typingTask?.cancel()
    }
}
