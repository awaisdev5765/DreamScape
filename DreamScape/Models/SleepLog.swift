import Foundation
import SwiftData

@Model
final class SleepLog {
    var id: String
    var sleepStart: Date
    var sleepEnd: Date?
    var duration: TimeInterval
    var qualityRating: SleepQuality?
    var sleepScore: Int
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        sleepStart: Date = .now,
        sleepEnd: Date? = nil,
        duration: TimeInterval = 0,
        qualityRating: SleepQuality? = nil,
        sleepScore: Int = 0
    ) {
        self.id = id
        self.sleepStart = sleepStart
        self.sleepEnd = sleepEnd
        self.duration = duration
        self.qualityRating = qualityRating
        self.sleepScore = sleepScore
        self.createdAt = .now
    }

    var durationHours: Double {
        duration / 3600.0
    }

    var bedtimeHour: Int {
        Calendar.current.component(.hour, from: sleepStart)
    }

    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    var formattedBedtime: String {
        sleepStart.formatted(date: .omitted, time: .shortened)
    }
}

// MARK: - Sleep Quality

enum SleepQuality: String, Codable, CaseIterable {
    case bad = "Bad"
    case okay = "Okay"
    case good = "Good"

    var emoji: String {
        switch self {
        case .bad: "😔"
        case .okay: "😐"
        case .good: "😊"
        }
    }

    var color: SwiftUI.Color {
        switch self {
        case .bad: DSColors.sleepBad
        case .okay: DSColors.sleepOkay
        case .good: DSColors.sleepGood
        }
    }

    var scoreMultiplier: Double {
        switch self {
        case .bad: 0.6
        case .okay: 0.8
        case .good: 1.0
        }
    }
}

import SwiftUI
