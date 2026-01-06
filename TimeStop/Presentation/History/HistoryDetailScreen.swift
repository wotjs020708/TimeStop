//
//  HistoryDetailScreen.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI

struct HistoryDetailScreen: View {
    let session: TimerSession

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header card
                headerCard

                // Stats summary
                statsCard

                // Attempts list
                attemptsSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("session_detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 50))
                .foregroundStyle(.primary)

            VStack(spacing: 4) {
                Text("\(session.targetSeconds)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("seconds")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Text(session.completedAt, style: .date)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.05))
        )
    }

    private var statsCard: some View {
        HStack(spacing: 0) {
            // Total attempts
            statItem(
                value: "\(session.attempts.count)",
                label: "attempts_count",
                icon: "repeat"
            )

            Divider()
                .frame(height: 40)

            // Best time
            if let best = session.bestAttempt {
                statItem(
                    value: String(format: "%.3f", best.actualSeconds),
                    label: "best_time",
                    icon: "medal.fill",
                    iconColor: .yellow
                )
            }

            Divider()
                .frame(height: 40)

            // Average difference
            statItem(
                value: String(format: "±%.2f", session.averageDifference),
                label: "avg_diff",
                icon: "chart.line.uptrend.xyaxis"
            )
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
        )
    }

    private func statItem(value: String, label: LocalizedStringKey, icon: String, iconColor: Color = .primary) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .monospacedDigit()

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var attemptsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("all_attempts")
                .font(.headline)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(Array(session.attempts.enumerated()), id: \.element.id) { index, attempt in
                    attemptRow(index: index, attempt: attempt)
                }
            }
        }
    }

    private func attemptRow(index: Int, attempt: AttemptRecord) -> some View {
        HStack {
            // Color indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(AttemptColors.color(for: index))
                .frame(width: 6)

            // Attempt number
            Text("#\(index + 1)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AttemptColors.color(for: index))
                .frame(width: 40, alignment: .leading)

            Spacer()

            // Actual time
            Text(String(format: "%.3fs", attempt.actualSeconds))
                .font(.body)
                .fontWeight(.medium)
                .monospacedDigit()

            Spacer()

            // Difference
            Text(formattedDifference(attempt.difference))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(accuracyColor(for: attempt.difference))
                .frame(width: 80, alignment: .trailing)

            // Medal for best
            if session.bestAttempt?.id == attempt.id {
                Image(systemName: "medal.fill")
                    .foregroundStyle(.yellow)
                    .padding(.leading, 8)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(session.bestAttempt?.id == attempt.id
                      ? Color.yellow.opacity(0.1)
                      : AttemptColors.color(for: index).opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AttemptColors.color(for: index).opacity(0.3), lineWidth: 1)
        )
    }

    private func formattedDifference(_ difference: Double) -> String {
        let sign = difference >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.3f", difference))s"
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
}

#Preview {
    NavigationStack {
        HistoryDetailScreen(session: TimerSession(
            id: UUID(),
            targetSeconds: 10,
            attempts: [
                AttemptRecord(id: UUID(), targetSeconds: 10, actualSeconds: 10.345),
                AttemptRecord(id: UUID(), targetSeconds: 10, actualSeconds: 9.712),
                AttemptRecord(id: UUID(), targetSeconds: 10, actualSeconds: 10.023),
            ],
            completedAt: Date()
        ))
    }
}
