//
//  ConnectivityManager.swift
//  TimeStop
//
//  Created by Claude on 1/31/26.
//

import Foundation
import WatchConnectivity
import Combine

/// Data structure for syncing timer sessions between iOS and watchOS
struct SessionData: Codable {
    let targetSeconds: Int
    let attempts: [AttemptData]
    let timestamp: Date
}

/// Codable version of Attempt for Watch Connectivity
struct AttemptData: Codable {
    let id: UUID
    let targetSeconds: Int
    let actualSeconds: Double
    
    var difference: Double {
        actualSeconds - Double(targetSeconds)
    }
}

/// Manages Watch Connectivity communication between iOS and watchOS
@MainActor
final class ConnectivityManager: NSObject, ObservableObject {
    static let shared = ConnectivityManager()
    
    @Published private(set) var isReachable: Bool = false
    @Published private(set) var lastReceivedSession: SessionData?
    
    private let session: WCSession
    
    private override init() {
        guard WCSession.isSupported() else {
            print("ConnectivityManager: WCSession is not supported on this device.")
            self.session = WCSession.default
            super.init()
            return
        }
        
        self.session = WCSession.default
        super.init()
        
        session.delegate = self
        session.activate()
    }
    
    /// Send current session state to counterpart device (latest state only)
    func syncSession(targetSeconds: Int, attempts: [Attempt]) {
        guard session.activationState == .activated else {
            print("ConnectivityManager: Session not activated yet")
            return
        }
        
        let sessionData = SessionData(
            targetSeconds: targetSeconds,
            attempts: attempts.map { AttemptData(id: $0.id, targetSeconds: $0.targetSeconds, actualSeconds: $0.actualSeconds) },
            timestamp: Date()
        )
        
        do {
            let context = try encodeSessionData(sessionData)
            try session.updateApplicationContext(context)
            print("ConnectivityManager: Synced session via updateApplicationContext")
        } catch {
            print("ConnectivityManager: Failed to sync session: \(error)")
        }
    }
    
    /// Send session with guaranteed delivery (queued)
    func transferSession(targetSeconds: Int, attempts: [Attempt]) {
        guard session.activationState == .activated else {
            print("ConnectivityManager: Session not activated yet")
            return
        }
        
        let sessionData = SessionData(
            targetSeconds: targetSeconds,
            attempts: attempts.map { AttemptData(id: $0.id, targetSeconds: $0.targetSeconds, actualSeconds: $0.actualSeconds) },
            timestamp: Date()
        )
        
        do {
            let context = try encodeSessionData(sessionData)
            session.transferUserInfo(context)
            print("ConnectivityManager: Transferred session via transferUserInfo")
        } catch {
            print("ConnectivityManager: Failed to transfer session: \(error)")
        }
    }
    
    private func encodeSessionData(_ sessionData: SessionData) throws -> [String: Any] {
        let data = try JSONEncoder().encode(sessionData)
        return ["session": data]
    }
    
    private func decodeSessionData(from message: [String: Any]) -> SessionData? {
        guard let data = message["session"] as? Data else {
            print("ConnectivityManager: No session data in message")
            return nil
        }
        
        do {
            let sessionData = try JSONDecoder().decode(SessionData.self, from: data)
            return sessionData
        } catch {
            print("ConnectivityManager: Failed to decode session data: \(error)")
            return nil
        }
    }
}

// MARK: - WCSessionDelegate

extension ConnectivityManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            if let error = error {
                print("ConnectivityManager: Activation failed with error: \(error)")
            } else {
                print("ConnectivityManager: Activation completed with state: \(activationState.rawValue)")
            }
            isReachable = session.isReachable
        }
    }
    
    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        print("ConnectivityManager: Session became inactive")
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        print("ConnectivityManager: Session deactivated")
        session.activate()
    }
    #endif
    
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            isReachable = session.isReachable
            print("ConnectivityManager: Reachability changed to \(session.isReachable)")
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            if let sessionData = decodeSessionData(from: applicationContext) {
                lastReceivedSession = sessionData
                print("ConnectivityManager: Received application context with \(sessionData.attempts.count) attempts")
            }
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        Task { @MainActor in
            if let sessionData = decodeSessionData(from: userInfo) {
                lastReceivedSession = sessionData
                print("ConnectivityManager: Received user info with \(sessionData.attempts.count) attempts")
            }
        }
    }
}
