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
    @State private var selectedTab = 0
    @State private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            TabView(selection: $selectedTab) {
                TimerTabView()
                    .tabItem {
                        Label("timer_tab", systemImage: "timer")
                    }
                    .tag(0)

                HistoryScreen()
                    .tabItem {
                        Label("history_tab", systemImage: "clock.arrow.circlepath")
                    }
                    .tag(1)
            }
        } else {
            OnboardingScreen {
                hasCompletedOnboarding = true
            }
        }
    }
}

/// Timer flow as a separate view for the tab
struct TimerTabView: View {
    @State private var navigationPath: [Screen] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            TimeInputScreen { targetSeconds in
                navigationPath.append(.timer(targetSeconds: targetSeconds))
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .onboarding:
                    EmptyView()

                case .timeInput:
                    TimeInputScreen { targetSeconds in
                        navigationPath.append(.timer(targetSeconds: targetSeconds))
                    }
                    .navigationBarBackButtonHidden(true)

                case .timer(let targetSeconds):
                    TimerScreen(targetSeconds: targetSeconds) { targetSeconds, attempts in
                        // Save to history
                        HistoryManager.shared.addSession(targetSeconds: targetSeconds, attempts: attempts)
                        navigationPath.append(.results(targetSeconds: targetSeconds, attempts: attempts))
                    }
                    .navigationBarBackButtonHidden(true)

                case .results(let targetSeconds, let attempts):
                    ResultsScreen(targetSeconds: targetSeconds, attempts: attempts) {
                        navigationPath = []
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
