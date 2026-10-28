import SwiftUI

struct BreathingCircle: View {
    var size: CGFloat = 220
    var primaryColor: Color = DSColors.moonGlow
    var secondaryColor: Color = DSColors.lavenderMist
    var isActive: Bool = true

    @State private var isExpanded = false
    @State private var rotation: Double = 0
    @State private var innerPulse = false

    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            primaryColor.opacity(0.3),
                            secondaryColor.opacity(0.1),
                            primaryColor.opacity(0.2),
                            secondaryColor.opacity(0.3),
                            primaryColor.opacity(0.3)
                        ],
                        center: .center
                    ),
                    lineWidth: 2
                )
                .frame(width: size + 40, height: size + 40)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(isExpanded ? 1.08 : 0.95)
                .opacity(isExpanded ? 0.6 : 0.3)

            // Middle blur ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            primaryColor.opacity(0.15),
                            primaryColor.opacity(0.05),
                            .clear
                        ],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size + 20, height: size + 20)
                .scaleEffect(isExpanded ? 1.05 : 0.92)
                .blur(radius: 8)

            // Core breathing circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            primaryColor.opacity(0.35),
                            secondaryColor.opacity(0.2),
                            primaryColor.opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
                .scaleEffect(isExpanded ? 1.0 : 0.75)

            // Inner luminous core
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.4),
                            primaryColor.opacity(0.3),
                            .clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: size * 0.25
                    )
                )
                .frame(width: size * 0.4, height: size * 0.4)
                .scaleEffect(innerPulse ? 1.15 : 0.85)
                .blur(radius: 4)

            // Center dot
            Circle()
                .fill(.white.opacity(0.8))
                .frame(width: 6, height: 6)
                .scaleEffect(innerPulse ? 1.2 : 0.8)
        }
        .onAppear {
            guard isActive else { return }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                isExpanded = true
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                innerPulse = true
            }
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Mini Breathing Indicator

struct MiniBreathingDot: View {
    var color: Color = DSColors.moonGlow
    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .scaleEffect(pulse ? 1.4 : 0.8)
            .opacity(pulse ? 1.0 : 0.5)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}
