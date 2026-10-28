import SwiftUI

@MainActor
enum DSHaptics {
    static func gentle() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
    }

    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.6)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func breatheIn() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.3)
    }

    static func breatheOut() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.15)
    }
}
