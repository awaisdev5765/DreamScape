import SwiftUI

// MARK: - DreamScape Design Tokens

enum DSColors {

    // MARK: - Core Palette (Midnight Sleep Gradients)

    static let midnight = Color(hex: "0A0E1A")
    static let deepNavy = Color(hex: "0F1628")
    static let cosmicBlue = Color(hex: "1A1F3D")
    static let twilight = Color(hex: "1E2A4A")
    static let nebula = Color(hex: "2D1B69")
    static let aurora = Color(hex: "1B3A5C")

    // MARK: - Accent Glows (Soft, Never Neon)

    static let moonGlow = Color(hex: "7B8FD4")
    static let starlight = Color(hex: "A8B8E8")
    static let lavenderMist = Color(hex: "B8A9E8")
    static let softCyan = Color(hex: "7ECFCF")
    static let warmAmber = Color(hex: "E8C87E")
    static let roseQuartz = Color(hex: "E8A9C4")

    // MARK: - Text

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.65)
    static let textTertiary = Color.white.opacity(0.4)

    // MARK: - Surface

    static let glassFill = Color.white.opacity(0.08)
    static let glassBorder = Color.white.opacity(0.12)
    static let glassHighlight = Color.white.opacity(0.18)

    // MARK: - Semantic

    static let sleepGood = Color(hex: "7ECFCF")
    static let sleepOkay = Color(hex: "E8C87E")
    static let sleepBad = Color(hex: "E88A7E")
}

// MARK: - Gradients

enum DSGradients {

    static let nightSky = LinearGradient(
        colors: [DSColors.midnight, DSColors.deepNavy, DSColors.cosmicBlue],
        startPoint: .top,
        endPoint: .bottom
    )

    static let auroraGlow = LinearGradient(
        colors: [DSColors.nebula.opacity(0.6), DSColors.aurora.opacity(0.4), DSColors.cosmicBlue.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let moonBeam = LinearGradient(
        colors: [DSColors.moonGlow.opacity(0.8), DSColors.starlight.opacity(0.4)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let sleepScore = AngularGradient(
        colors: [DSColors.moonGlow, DSColors.lavenderMist, DSColors.softCyan, DSColors.moonGlow],
        center: .center
    )

    static let glassShimmer = LinearGradient(
        colors: [Color.white.opacity(0.15), Color.white.opacity(0.05), Color.white.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Spacing

enum DSSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Radius

enum DSRadius {
    static let sm: CGFloat = 12
    static let md: CGFloat = 20
    static let lg: CGFloat = 28
    static let xl: CGFloat = 36
    static let pill: CGFloat = 100
}

// MARK: - Animation Curves (Calm, Slow)

enum DSAnimation {
    static let gentle = Animation.easeInOut(duration: 0.4)
    static let slow = Animation.easeInOut(duration: 0.6)
    static let breathing = Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)
    static let drift = Animation.easeInOut(duration: 8.0).repeatForever(autoreverses: true)
    static let fadeIn = Animation.easeOut(duration: 0.5)
    static let spring = Animation.spring(response: 0.5, dampingFraction: 0.8)
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
