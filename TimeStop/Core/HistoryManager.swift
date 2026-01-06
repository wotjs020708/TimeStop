//
//  HistoryManager.swift
//  TimeStop
//
//  Created by Claude on 1/6/26.
//

import Foundation
import Combine

/// Represents a completed timer session with all attempts
struct TimerSession: Codable, Identifiable, Equatable {
    let id: UUID
    let targetSeconds: Int
    let attempts: [AttemptRecord]
    let completedAt: Date

    var bestAttempt: AttemptRecord? {
        attempts.min { abs($0.difference) < abs($1.difference) }
    }

    var averageDifference: Double {
        guard !attempts.isEmpty else { return 0 }
        return attempts.map { abs($0.difference) }.reduce(0, +) / Double(attempts.count)
    }
}

/// Codable version of Attempt for persistence
struct AttemptRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let targetSeconds: Int
    let actualSeconds: Double

    var difference: Double {
        actualSeconds - Double(targetSeconds)
    }

    init(from attempt: Attempt) {
        self.id = attempt.id
        self.targetSeconds = attempt.targetSeconds
        self.actualSeconds = attempt.actualSeconds
    }

    init(id: UUID, targetSeconds: Int, actualSeconds: Double) {
        self.id = id
        self.targetSeconds = targetSeconds
        self.actualSeconds = actualSeconds
    }
}

/// Manages saving and loading timer session history
@MainActor
class HistoryManager: ObservableObject {
    static let shared = HistoryManager()

    @Published private(set) var sessions: [TimerSession] = []

    private let userDefaultsKey = "timerSessions"

    private init() {
        loadSessions()
    }

    func addSession(targetSeconds: Int, attempts: [Attempt]) {
        let session = TimerSession(
            id: UUID(),
            targetSeconds: targetSeconds,
            attempts: attempts.map { AttemptRecord(from: $0) },
            completedAt: Date()
        )
        sessions.insert(session, at: 0)
        saveSessions()
    }

    func deleteSession(_ session: TimerSession) {
        sessions.removeAll { $0.id == session.id }
        saveSessions()
    }

    func clearAllSessions() {
        sessions.removeAll()
        saveSessions()
    }

    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([TimerSession].self, from: data) {
            sessions = decoded
        }
    }
}
