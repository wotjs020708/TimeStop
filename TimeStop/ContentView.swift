//
//  ContentView.swift
//  TimeStop
//
//  Created by 어재선 on 1/6/26.
//

import SwiftUI

enum Screen: Hashable {
    case onboarding
    case timeInput
    case timer(targetSeconds: Int)
    case results(targetSeconds: Int, attempts: [Attempt])
}

struct ContentView: View {
    @State private var navigationPath: [Screen] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            OnboardingScreen {
                navigationPath.append(.timeInput)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .onboarding:
                    OnboardingScreen {
                        navigationPath.append(.timeInput)
                    }
                    .navigationBarBackButtonHidden(true)

                case .timeInput:
                    TimeInputScreen { targetSeconds in
                        navigationPath.append(.timer(targetSeconds: targetSeconds))
                    }
                    .navigationBarBackButtonHidden(true)

                case .timer(let targetSeconds):
                    TimerScreen(targetSeconds: targetSeconds) { targetSeconds, attempts in
                        navigationPath.append(.results(targetSeconds: targetSeconds, attempts: attempts))
                    }
                    .navigationBarBackButtonHidden(true)

                case .results(let targetSeconds, let attempts):
                    ResultsScreen(targetSeconds: targetSeconds, attempts: attempts) {
                        navigationPath = [.timeInput]
                    }
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
