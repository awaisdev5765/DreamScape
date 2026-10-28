import SwiftUI

struct AmbientBackground: View {
    var style: AmbientStyle = .nightSky
    @State private var phase1 = false
    @State private var phase2 = false
    @State private var phase3 = false

    var body: some View {
        ZStack {
            // Base color
            DSColors.midnight.ignoresSafeArea()

            // Layer 1: Deep gradient
            style.baseGradient
                .ignoresSafeArea()

            // Layer 2: Floating orbs
            floatingOrb(
                color: style.orbColor1,
                size: 300,
                offset: phase1 ? CGSize(width: 80, height: -120) : CGSize(width: -60, height: 100),
                blur: 80
            )

            floatingOrb(
                color: style.orbColor2,
                size: 250,
                offset: phase2 ? CGSize(width: -100, height: 80) : CGSize(width: 70, height: -80),
                blur: 90
            )

            floatingOrb(
                color: style.orbColor3,
                size: 200,
                offset: phase3 ? CGSize(width: 50, height: 150) : CGSize(width: -40, height: -60),
                blur: 70
            )

            // Layer 3: Subtle noise overlay
            Rectangle()
                .fill(.black.opacity(0.15))
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                phase1 = true
            }
            withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true).delay(2)) {
                phase2 = true
            }
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true).delay(4)) {
                phase3 = true
            }
        }
    }

    private func floatingOrb(color: Color, size: CGFloat, offset: CGSize, blur: CGFloat) -> some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: blur)
            .offset(offset)
            .opacity(0.4)
    }
}

// MARK: - Ambient Style

enum AmbientStyle {
    case nightSky
    case deepOcean
    case aurora
    case sleepMode

    var baseGradient: LinearGradient {
        switch self {
        case .nightSky:
            LinearGradient(
                colors: [DSColors.midnight, DSColors.deepNavy, Color(hex: "0D1225")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .deepOcean:
            LinearGradient(
                colors: [Color(hex: "0A1628"), Color(hex: "0F2135"), Color(hex: "071420")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .aurora:
            LinearGradient(
                colors: [DSColors.midnight, DSColors.nebula.opacity(0.3), DSColors.midnight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sleepMode:
            LinearGradient(
                colors: [Color(hex: "050810"), Color(hex: "0A0E1A"), Color(hex: "050810")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    var orbColor1: Color {
        switch self {
        case .nightSky: DSColors.cosmicBlue
        case .deepOcean: DSColors.aurora
        case .aurora: DSColors.nebula
        case .sleepMode: DSColors.cosmicBlue.opacity(0.5)
        }
    }

    var orbColor2: Color {
        switch self {
        case .nightSky: DSColors.nebula.opacity(0.6)
        case .deepOcean: DSColors.softCyan.opacity(0.3)
        case .aurora: DSColors.moonGlow.opacity(0.3)
        case .sleepMode: DSColors.nebula.opacity(0.3)
        }
    }

    var orbColor3: Color {
        switch self {
        case .nightSky: DSColors.twilight
        case .deepOcean: DSColors.moonGlow.opacity(0.2)
        case .aurora: DSColors.lavenderMist.opacity(0.3)
        case .sleepMode: DSColors.twilight.opacity(0.3)
        }
    }
}
