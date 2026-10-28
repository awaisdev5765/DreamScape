import SwiftUI

struct StarfieldView: View {
    var starCount: Int = 80
    @State private var stars: [Star] = []
    @State private var twinklePhase = false

    var body: some View {
        Canvas { context, size in
            for star in stars {
                let opacity = star.baseOpacity * (twinklePhase && star.twinkles ? 0.3 : 1.0)
                let rect = CGRect(
                    x: star.x * size.width,
                    y: star.y * size.height,
                    width: star.size,
                    height: star.size
                )
                context.opacity = opacity
                context.fill(Circle().path(in: rect), with: .color(.white))
            }
        }
        .onAppear {
            stars = (0..<starCount).map { _ in
                Star(
                    x: Double.random(in: 0...1),
                    y: Double.random(in: 0...0.6),
                    size: Double.random(in: 1...3),
                    baseOpacity: Double.random(in: 0.2...0.8),
                    twinkles: Bool.random()
                )
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                twinklePhase = true
            }
        }
        .allowsHitTesting(false)
    }
}

private struct Star {
    let x: Double
    let y: Double
    let size: Double
    let baseOpacity: Double
    let twinkles: Bool
}

// MARK: - Floating Particles

struct FloatingParticles: View {
    var count: Int = 20
    var color: Color = DSColors.moonGlow

    @State private var particles: [Particle] = []
    @State private var animate = false

    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let yOffset = animate ? particle.driftY : 0
                let rect = CGRect(
                    x: particle.x * size.width,
                    y: (particle.y * size.height) + yOffset,
                    width: particle.size,
                    height: particle.size
                )
                context.opacity = particle.opacity * (animate ? 0.6 : 1.0)
                context.fill(Circle().path(in: rect), with: .color(color))
            }
        }
        .onAppear {
            particles = (0..<count).map { _ in
                Particle(
                    x: Double.random(in: 0...1),
                    y: Double.random(in: 0...1),
                    size: Double.random(in: 2...5),
                    opacity: Double.random(in: 0.1...0.4),
                    driftY: Double.random(in: -30...30)
                )
            }
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
        .allowsHitTesting(false)
    }
}

private struct Particle {
    let x: Double
    let y: Double
    let size: Double
    let opacity: Double
    let driftY: Double
}
