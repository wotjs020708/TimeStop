//
//  TimerScreen.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import SwiftUI

struct TimerScreen: View {
    @StateObject private var viewModel: TimerViewModel
    let onFinish: (Int, [Attempt]) -> Void

    @State private var isBlinking = false
    @State private var shimmerOffset: CGFloat = -1.0
    @State private var shimmerTimer: Timer?
    @Environment(\.colorScheme) private var colorScheme

    init(targetSeconds: Int, onFinish: @escaping (Int, [Attempt]) -> Void) {
        self._viewModel = StateObject(wrappedValue: TimerViewModel(targetSeconds: targetSeconds))
        self.onFinish = onFinish
    }
    
    // Schedule next shimmer with random interval (0.8s ~ 2.5s)
    private func scheduleRandomShimmer() {
        let randomDelay = Double.random(in: 0.8...2.5)
        shimmerTimer?.invalidate()
        shimmerTimer = Timer.scheduledTimer(withTimeInterval: randomDelay, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                shimmerOffset = 2.0
            }
            // Reset after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                shimmerOffset = -1.0
                if viewModel.state.timerState == .ready {
                    scheduleRandomShimmer()
                }
            }
        }
    }
    
    private func stopShimmer() {
        shimmerTimer?.invalidate()
        shimmerTimer = nil
        shimmerOffset = -1.0
    }

    // Current attempt index for color selection
    private var currentAttemptIndex: Int {
        viewModel.state.attempts.count
    }

    var body: some View {
        ZStack {
            // Solid color background when timer is running - immediate, no transition
            if viewModel.state.timerState == .running {
                AttemptColors.color(for: currentAttemptIndex, colorScheme: colorScheme)
                    .ignoresSafeArea()
            }
            // Main content
            VStack(spacing: 32) {
                Spacer()

                // Timer display - visible briefly at start then fades out, then show blinking STOP instruction
                if viewModel.state.timerState == .running && viewModel.state.elapsedTime < 0.5 {
                    Text(formatTime(viewModel.state.elapsedTime))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        .opacity(max(0, 1.0 - (viewModel.state.elapsedTime / 0.3)))
                        .animation(.easeOut(duration: 0.1), value: viewModel.state.elapsedTime)
                } else if viewModel.state.timerState == .running && viewModel.state.elapsedTime >= 0.5 {
                    // Blinking STOP instruction after initial fade
                    VStack(spacing: 16) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.white)

                        Text("stop")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("tap_to_stop")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .opacity(isBlinking ? 0.3 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isBlinking)
                    .onAppear {
                        isBlinking = true
                    }
                } else if viewModel.state.timerState == .stopped {
                    // Recording complete state - show the ACTUAL saved time from the last attempt
                    let lastAttemptTime = viewModel.state.attempts.last?.actualSeconds ?? viewModel.state.elapsedTime
                    VStack(spacing: 24) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.green)

                        VStack(spacing: 6) {
                            Text(formatTime(lastAttemptTime))
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                                .monospacedDigit()

                            Text("seconds")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onAppear {
                        isBlinking = false
                    }
                } else if viewModel.state.timerState == .ready {
                    // Ready state - show icon with skeleton shimmer effect
                    VStack(spacing: 16) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.primary)

                        Text("start")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .overlay(
                        GeometryReader { geometry in
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.4),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: geometry.size.width * 0.6)
                            .offset(x: geometry.size.width * shimmerOffset)
                            .blur(radius: 3)
                        }
                        .mask(
                            VStack(spacing: 16) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 60))
                                Text("start")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                        )
                    )
                    .onAppear {
                        isBlinking = false
                        scheduleRandomShimmer()
                    }
                    .onDisappear {
                        stopShimmer()
                    }
                }

                Spacer()

                // Bottom buttons
                if viewModel.state.timerState == .stopped {
                    VStack(spacing: 12) {
                        // Continue button
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            viewModel.send(.continueTapped)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title3)
                                Text("continue")
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

                        // Finish button with long press - RED color
                        Button {} label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.red.opacity(0.6), lineWidth: 2)

                                // Progress fill - red
                                GeometryReader { geometry in
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.red.opacity(0.3))
                                        .frame(width: geometry.size.width * viewModel.state.finishPressProgress)
                                        .animation(.linear(duration: 0.05), value: viewModel.state.finishPressProgress)
                                }

                                HStack(spacing: 12) {
                                    Image(systemName: "stop.circle.fill")
                                        .font(.title3)
                                    Text("hold_to_finish")
                                        .font(.subheadline)
                                }
                                .foregroundStyle(.red)
                                .padding(.vertical, 16)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                        }
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 1.5)
                                .onChanged { _ in
                                    // Haptic when starting long press
                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                    impact.impactOccurred()
                                    viewModel.send(.finishPressed)
                                }
                                .onEnded { _ in
                                    // Will be handled by side effect
                                }
                        )
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { _ in
                                    viewModel.send(.finishReleased)
                                }
                        )
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded { _ in
                                    // Light haptic on tap
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()

            if viewModel.state.timerState == .ready {
                viewModel.send(.startTapped)
            } else if viewModel.state.timerState == .running {
                viewModel.send(.stopTapped)
            }
        }
        .onReceive(viewModel.sideEffect) { effect in
            switch effect {
            case .navigateToResults(let targetSeconds, let attempts):
                onFinish(targetSeconds, attempts)
            }
        }
    }

    // Format time with milliseconds (e.g., "10.345")
    private func formatTime(_ time: TimeInterval) -> String {
        String(format: "%.3f", time)
    }
}

#Preview {
    TimerScreen(targetSeconds: 10, onFinish: { _, _ in })
}
