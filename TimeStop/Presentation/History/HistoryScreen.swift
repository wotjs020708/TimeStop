//
//  HistoryScreen.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI

struct HistoryScreen: View {
    @ObservedObject private var historyManager = HistoryManager.shared

    var body: some View {
        NavigationStack {
            Group {
                if historyManager.sessions.isEmpty {
                    emptyStateView
                } else {
                    sessionListView
                }
            }
            .navigationTitle("history_title")
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("no_history")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var sessionListView: some View {
        List {
            ForEach(historyManager.sessions) { session in
                SessionRowView(session: session)
            }
            .onDelete(perform: deleteSession)
        }
        .listStyle(.plain)
    }

    private func deleteSession(at offsets: IndexSet) {
        for index in offsets {
            let session = historyManager.sessions[index]
            historyManager.deleteSession(session)
        }
    }
}

struct SessionRowView: View {
    let session: TimerSession

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Target time and date
            HStack {
                Label("\(session.targetSeconds)s", systemImage: "target")
                    .font(.headline)

                Spacer()

                Text(session.completedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Attempts summary
            HStack(spacing: 16) {
                // Number of attempts
                Label("\(session.attempts.count)", systemImage: "repeat")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Best attempt
                if let best = session.bestAttempt {
                    HStack(spacing: 4) {
                        Image(systemName: "medal.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.3f", best.actualSeconds))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }

                Spacer()

                // Average accuracy
                Text(String(format: "±%.2fs", session.averageDifference))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(accuracyColor(for: session.averageDifference).opacity(0.2))
                    )
                    .foregroundStyle(accuracyColor(for: session.averageDifference))
            }

            // Attempt colors preview
            HStack(spacing: 4) {
                ForEach(Array(session.attempts.prefix(6).enumerated()), id: \.element.id) { index, _ in
                    Circle()
                        .fill(AttemptColors.color(for: index))
                        .frame(width: 12, height: 12)
                }
                if session.attempts.count > 6 {
                    Text("+\(session.attempts.count - 6)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func accuracyColor(for difference: Double) -> Color {
        if difference < 0.5 {
            return .green
        } else if difference < 1.0 {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    HistoryScreen()
}
