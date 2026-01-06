//
//  TimeInputScreen.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI

struct TimeInputScreen: View {
    @StateObject private var viewModel = TimeInputViewModel()
    let onStart: (Int) -> Void

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "timer")
                    .font(.system(size: 50))
                    .foregroundStyle(.primary)

                // Large time display
                VStack(spacing: 8) {
                    Text("\(viewModel.state.targetSeconds)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .monospacedDigit()

                    Text("seconds")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }

            // Slider
            VStack(spacing: 16) {
                Slider(
                    value: Binding(
                        get: { Double(viewModel.state.targetSeconds) },
                        set: { newValue in
                            viewModel.send(.sliderChanged(Int(newValue)))
                        }
                    ),
                    in: 1...60,
                    step: 1
                )
                .tint(.primary)

                HStack {
                    Text("1")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("60")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 8)

            Spacer()

            Button {
                viewModel.send(.startTapped)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.title3)
                    Text("start")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.primary)
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .onReceive(viewModel.sideEffect) { effect in
            switch effect {
            case .navigateToTimer(let targetSeconds):
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                onStart(targetSeconds)

            case .triggerHaptic:
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            }
        }
    }
}

#Preview {
    TimeInputScreen(onStart: { _ in })
}
