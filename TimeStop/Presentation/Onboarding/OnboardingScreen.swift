//
//  OnboardingScreen.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI

struct OnboardingScreen: View {
    @StateObject private var viewModel = OnboardingViewModel()
    let onGetStarted: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.primary)

                Text("onboarding_welcome")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }

            VStack(spacing: 8) {
                Text(viewModel.state.displayedText)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 50)
                    .fixedSize(horizontal: false, vertical: true)

                if !viewModel.state.isAnimationComplete {
                    ProgressView()
                        .padding(.top, 4)
                }
            }

            Spacer()

            Button {
                viewModel.send(.getStartedTapped)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                    Text("get_started")
                        .font(.headline)
                }
                .foregroundStyle(colorScheme == .dark ? .black : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.primary)
                )
            }
            .disabled(!viewModel.state.isAnimationComplete)
            .opacity(viewModel.state.isAnimationComplete ? 1 : 0.6)
            .animation(.easeInOut, value: viewModel.state.isAnimationComplete)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .onAppear {
            viewModel.send(.onAppear)
        }
        .onReceive(viewModel.sideEffect) { effect in
            switch effect {
            case .navigateToTimeInput:
                onGetStarted()
            }
        }
    }
}

#Preview {
    OnboardingScreen(onGetStarted: {})
}
