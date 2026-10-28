import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: String
    var name: String
    var email: String
    var sleepGoal: SleepGoal
    var sleepProblem: SleepProblem
    var preferredMood: PreferredMood
    var subscriptionStatus: SubscriptionStatus
    var subscriptionExpiry: Date?
    var productId: String?
    var createdAt: Date
    var hasCompletedOnboarding: Bool

    init(
        id: String = UUID().uuidString,
        name: String = "",
        email: String = "",
        sleepGoal: SleepGoal = .sevenToEight,
        sleepProblem: SleepProblem = .stress,
        preferredMood: PreferredMood = .calm,
        subscriptionStatus: SubscriptionStatus = .free,
        subscriptionExpiry: Date? = nil,
        productId: String? = nil,
        hasCompletedOnboarding: Bool = false
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.sleepGoal = sleepGoal
        self.sleepProblem = sleepProblem
        self.preferredMood = preferredMood
        self.subscriptionStatus = subscriptionStatus
        self.subscriptionExpiry = subscriptionExpiry
        self.productId = productId
        self.createdAt = .now
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}

// MARK: - Enums

enum SleepGoal: String, Codable, CaseIterable {
    case sixToSeven = "6-7 hours"
    case sevenToEight = "7-8 hours"
    case eightToNine = "8-9 hours"
    case ninePlus = "9+ hours"

    var icon: String {
        switch self {
        case .sixToSeven: "moon"
        case .sevenToEight: "moon.stars"
        case .eightToNine: "moon.stars.fill"
        case .ninePlus: "sparkles"
        }
    }
}

enum SleepProblem: String, Codable, CaseIterable {
    case stress = "Stress & Anxiety"
    case insomnia = "Can't Fall Asleep"
    case lateSleep = "Sleep Too Late"
    case wakeUps = "Wake Up Often"

    var icon: String {
        switch self {
        case .stress: "brain.head.profile"
        case .insomnia: "bed.double"
        case .lateSleep: "clock"
        case .wakeUps: "alarm"
        }
    }

    var shortLabel: String {
        switch self {
        case .stress: "Stress"
        case .insomnia: "Insomnia"
        case .lateSleep: "Late Sleep"
        case .wakeUps: "Wake-ups"
        }
    }
}

enum PreferredMood: String, Codable, CaseIterable {
    case calm = "Calm & Still"
    case nature = "Nature Sounds"
    case guided = "Guided Voice"

    var icon: String {
        switch self {
        case .calm: "leaf"
        case .nature: "cloud.rain"
        case .guided: "person.wave.2"
        }
    }
}

enum SubscriptionStatus: String, Codable {
    case free
    case premium
    case expired
}
