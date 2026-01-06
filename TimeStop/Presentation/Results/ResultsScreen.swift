//
//  ResultsScreen.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI

struct ResultsScreen: View {
    @StateObject private var viewModel: ResultsViewModel
    let onTryAgain: () -> Void

    init(targetSeconds: Int, attempts: [Attempt], onTryAgain: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: ResultsViewModel(targetSeconds: targetSeconds, attempts: attempts))
        self.onTryAgain = onTryAgain
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.primary)

                Text("results_title")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.top, 16)

            // Target time
            VStack(spacing: 6) {
                Text("target_time")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Text("\(viewModel.state.targetSeconds)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    + Text(" ")
                    + Text("seconds")
                        .font(.title3)
                        .foregroundStyle(.secondary)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.1))
            )

            // Attempts list
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(Array(viewModel.state.attempts.enumerated()), id: \.element.id) { index, attempt in
                        HStack {
                            // Color indicator bar
                            RoundedRectangle(cornerRadius: 2)
                                .fill(attemptColor(for: index))
                                .frame(width: 4)

                            // Attempt number with icon
                            HStack(spacing: 8) {
                                Image(systemName: "\(index + 1).circle.fill")
                                    .font(.body)
                                    .foregroundStyle(attemptColor(for: index))

                                Text(String(format: NSLocalizedString("attempt", comment: ""), index + 1))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                            }

                            Spacer()

                            // Accuracy with milliseconds
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(formatTime(attempt.actualSeconds))
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                    .monospacedDigit()

                                Text(formattedDifference(attempt.difference))
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundStyle(accuracyColor(for: attempt.difference))
                            }

                            // Medal for best attempt
                            if let bestAttempt = viewModel.state.bestAttempt,
                               attempt.id == bestAttempt.id {
                                Image(systemName: "medal.fill")
                                    .font(.body)
                                    .foregroundStyle(.yellow)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(attemptBackgroundColor(for: index, isBest: viewModel.state.bestAttempt?.id == attempt.id))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(attemptColor(for: index).opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }

            // Try again button
            Button {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                viewModel.send(.tryAgainTapped)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                    Text("try_again")
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
        .padding(.vertical, 20)
        .onReceive(viewModel.sideEffect) { effect in
            switch effect {
            case .navigateToTimeInput:
                onTryAgain()
            }
        }
    }

    // Format time with milliseconds (e.g., "10.345")
    private func formatTime(_ time: TimeInterval) -> String {
        String(format: "%.3f", time)
    }

    private func formattedDifference(_ difference: Double) -> String {
        let sign = difference >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.3f", difference))"
    }

    private func accuracyColor(for difference: Double) -> Color {
        let absDiff = abs(difference)
        if absDiff < 0.5 {
            return .green
        } else if absDiff < 1.0 {
            return .orange
        } else {
            return .red
        }
    }

    private func attemptColor(for index: Int) -> Color {
        AttemptColors.color(for: index)
    }

    private func attemptBackgroundColor(for index: Int, isBest: Bool) -> Color {
        if isBest {
            return .yellow.opacity(0.15)
        }
        return attemptColor(for: index).opacity(0.1)
    }
}

#Preview {
    ResultsScreen(
        targetSeconds: 10,
        attempts: [
            Attempt(id: UUID(), targetSeconds: 10, actualSeconds: 10.345),
            Attempt(id: UUID(), targetSeconds: 10, actualSeconds: 9.712),
            Attempt(id: UUID(), targetSeconds: 10, actualSeconds: 11.203),
        ],
        onTryAgain: {}
    )
}
