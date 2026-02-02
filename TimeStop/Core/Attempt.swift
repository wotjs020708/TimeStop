//
//  Attempt.swift
//  TimeStop
//
//  Created by Claude on 2/2/26.
//

import Foundation

enum TimerState: Equatable, Codable {
    case ready
    case running
    case stopped
}

struct Attempt: Equatable, Identifiable, Hashable, Codable {
    let id: UUID
    let targetSeconds: Int
    let actualSeconds: Double

    var difference: Double {
        actualSeconds - Double(targetSeconds)
    }
}
