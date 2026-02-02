//
//  WatchTimerScreen.swift
//  TimeStopWatch Watch App
//
//  Created by Claude on 1/31/26.
//

import SwiftUI

struct WatchTimerScreen: View {
    @StateObject var viewModel: WatchTimerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text(formatTime(viewModel.state.elapsedTime))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)
            
            HStack(spacing: 12) {
                if viewModel.state.timerState == .ready || viewModel.state.timerState == .stopped {
                    Button(action: { viewModel.send(.startTapped) }) {
                        Label(String(localized: "start"), systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button(action: { viewModel.send(.stopTapped) }) {
                        Label(String(localized: "stop"), systemImage: "stop.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                
                if viewModel.state.timerState == .stopped {
                    Button(action: { viewModel.send(.resetTapped) }) {
                        Label(String(localized: "watch_reset"), systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            if !viewModel.state.attempts.isEmpty {
                List {
                    ForEach(viewModel.state.attempts) { attempt in
                        HStack {
                            Text("#\(viewModel.state.attempts.firstIndex(where: { $0.id == attempt.id })! + 1)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(formatTime(attempt.actualSeconds))
                                .font(.body.monospaced())
                            
                            Spacer()
                            
                            Text(formatDifference(attempt.difference))
                                .font(.caption.monospaced())
                                .foregroundStyle(attempt.difference >= 0 ? .red : .green)
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle(String(localized: "watch_timer"))
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        String(format: "%.2f", seconds)
    }
    
    private func formatDifference(_ difference: Double) -> String {
        let sign = difference >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", difference))s"
    }
}

#Preview {
    WatchTimerScreen(viewModel: WatchTimerViewModel(targetSeconds: 10))
}
