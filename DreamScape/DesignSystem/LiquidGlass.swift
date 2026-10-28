import SwiftUI

// MARK: - Liquid Glass Card Modifier

struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var opacity: Double
    var borderOpacity: Double

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
            }
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DSColors.glassFill)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(DSGradients.glassShimmer, lineWidth: 0.5)
                    .opacity(borderOpacity)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Floating Glass Button Modifier

struct GlassButtonModifier: ViewModifier {
    var isPressed: Bool

    func body(content: Content) -> some View {
        content
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
            }
            .background {
                Capsule()
                    .fill(DSColors.moonGlow.opacity(isPressed ? 0.3 : 0.15))
            }
            .overlay {
                Capsule()
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            }
            .clipShape(Capsule())
            .shadow(color: DSColors.moonGlow.opacity(0.3), radius: isPressed ? 8 : 16, x: 0, y: isPressed ? 4 : 8)
            .scaleEffect(isPressed ? 0.97 : 1.0)
    }
}

// MARK: - Ambient Glow Modifier

struct AmbientGlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat
    var isAnimating: Bool

    @State private var phase: Bool = false

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(phase ? 0.4 : 0.2), radius: radius, x: 0, y: 0)
            .onAppear {
                if isAnimating {
                    withAnimation(DSAnimation.breathing) {
                        phase = true
                    }
                }
            }
    }
}

// MARK: - Glass Blur Background

struct FrostedBackground: View {
    var cornerRadius: CGFloat = DSRadius.lg

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.04),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            }
    }
}

// MARK: - iOS 26 Liquid Glass Effect

struct LiquidGlassEffect: ViewModifier {
    var intensity: Double

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: DSRadius.lg))
        } else {
            content
                .modifier(LiquidGlassModifier(
                    cornerRadius: DSRadius.lg,
                    opacity: intensity,
                    borderOpacity: 0.8
                ))
        }
    }
}

// MARK: - View Extensions

extension View {
    func liquidGlass(
        cornerRadius: CGFloat = DSRadius.lg,
        opacity: Double = 0.7,
        borderOpacity: Double = 0.8
    ) -> some View {
        modifier(LiquidGlassModifier(
            cornerRadius: cornerRadius,
            opacity: opacity,
            borderOpacity: borderOpacity
        ))
    }

    func glassButton(isPressed: Bool = false) -> some View {
        modifier(GlassButtonModifier(isPressed: isPressed))
    }

    func ambientGlow(
        color: Color = DSColors.moonGlow,
        radius: CGFloat = 20,
        animated: Bool = true
    ) -> some View {
        modifier(AmbientGlowModifier(color: color, radius: radius, isAnimating: animated))
    }

    func nativeLiquidGlass(intensity: Double = 0.7) -> some View {
        modifier(LiquidGlassEffect(intensity: intensity))
    }
}
