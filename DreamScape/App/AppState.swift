import SwiftUI
import SwiftData
import Observation

@Observable
final class AppState {
    var currentTab: AppTab = .home
    var isOnboarding: Bool = true
    var showSleepMode: Bool = false
    var showMorningCheck: Bool = false
    var showPaywall: Bool = false

    // MARK: - Onboarding State

    var onboardingStep: Int = 0
    var selectedSleepGoal: SleepGoal = .sevenToEight
    var selectedSleepProblem: SleepProblem = .stress
    var selectedMood: PreferredMood = .calm

    // MARK: - Active Session

    var activeSleepStart: Date?
    var selectedAmbientSound: AmbientSound = .rain
    var ambientVolume: Float = 0.7

    func completeOnboarding() {
        withAnimation(DSAnimation.slow) {
            isOnboarding = false
        }
    }

    func startSleepMode() {
        activeSleepStart = .now
        withAnimation(DSAnimation.slow) {
            showSleepMode = true
        }
    }

    func endSleepMode() {
        withAnimation(DSAnimation.slow) {
            showSleepMode = false
            showMorningCheck = true
        }
    }

    func completeMorningCheck() {
        activeSleepStart = nil
        withAnimation(DSAnimation.gentle) {
            showMorningCheck = false
        }
    }
}

// MARK: - Tabs

enum AppTab: String, CaseIterable {
    case home = "Home"
    case meditate = "Meditate"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .home: "moon.stars"
        case .meditate: "leaf"
        case .settings: "gearshape"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: "moon.stars.fill"
        case .meditate: "leaf.fill"
        case .settings: "gearshape.fill"
        }
    }
}
