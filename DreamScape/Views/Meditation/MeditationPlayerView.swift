import SwiftUI

struct MeditationPlayerView: View {
    let meditation: Meditation
    var onDismiss: () -> Void

    @State private var isPlaying = false
    @State private var progress: CGFloat = 0
    @State private var elapsedTime: TimeInterval = 0
    @State private var showControls = true

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            AmbientBackground(style: .sleepMode)
                .ignoresSafeArea()

            FloatingParticles(count: 12, color: meditation.category.gradient.first ?? DSColors.moonGlow)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        DSHaptics.tap()
                        onDismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(DSColors.textSecondary)
                            .frame(width: 40, height: 40)
                            .liquidGlass(cornerRadius: 20, opacity: 0.4)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text(meditation.category.rawValue)
                            .font(DSFont.tag)
                            .foregroundStyle(DSColors.textTertiary)
                            .textCase(.uppercase)
                            .tracking(1)
                    }

                    Spacer()

                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.top, DSSpacing.lg)

                Spacer()

                // Center visualization
                VStack(spacing: DSSpacing.xxl) {
                    BreathingCircle(
                        size: 200,
                        primaryColor: meditation.category.gradient.first ?? DSColors.moonGlow,
                        secondaryColor: meditation.category.gradient.last ?? DSColors.lavenderMist,
                        isActive: isPlaying
                    )

                    VStack(spacing: DSSpacing.sm) {
                        Text(meditation.title)
                            .font(DSFont.headlineLarge)
                            .foregroundStyle(DSColors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(meditation.subtitle)
                            .font(DSFont.bodyMedium)
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }

                Spacer()

                // Progress + Controls
                VStack(spacing: DSSpacing.xl) {
                    // Progress bar
                    VStack(spacing: DSSpacing.sm) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 3)

                                Capsule()
                                    .fill(DSColors.moonGlow.opacity(0.6))
                                    .frame(width: geo.size.width * progress, height: 3)
                            }
                        }
                        .frame(height: 3)

                        HStack {
                            Text(formatTime(elapsedTime))
                                .font(DSFont.tag)
                                .foregroundStyle(DSColors.textTertiary)
                                .monospacedDigit()

                            Spacer()

                            Text(formatTime(meditation.duration))
                                .font(DSFont.tag)
                                .foregroundStyle(DSColors.textTertiary)
                                .monospacedDigit()
                        }
                    }

                    // Playback controls
                    HStack(spacing: DSSpacing.xxl) {
                        Button {
                            DSHaptics.gentle()
                            seekBackward()
                        } label: {
                            Image(systemName: "gobackward.15")
                                .font(.title2)
                                .foregroundStyle(DSColors.textSecondary)
                        }

                        Button {
                            DSHaptics.tap()
                            withAnimation(DSAnimation.gentle) {
                                isPlaying.toggle()
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(DSColors.moonGlow.opacity(0.2))
                                    .frame(width: 72, height: 72)

                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 72, height: 72)

                                Circle()
                                    .stroke(DSColors.moonGlow.opacity(0.4), lineWidth: 0.5)
                                    .frame(width: 72, height: 72)

                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.title)
                                    .foregroundStyle(.white)
                                    .offset(x: isPlaying ? 0 : 2)
                            }
                            .shadow(color: DSColors.moonGlow.opacity(0.3), radius: 16)
                        }

                        Button {
                            DSHaptics.gentle()
                            seekForward()
                        } label: {
                            Image(systemName: "goforward.30")
                                .font(.title2)
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.xl)
                .padding(.bottom, DSSpacing.xxl)
            }
        }
        .onReceive(timer) { _ in
            guard isPlaying else { return }
            if elapsedTime < meditation.duration {
                elapsedTime += 1
                progress = elapsedTime / meditation.duration
            } else {
                isPlaying = false
            }
        }
    }

    // MARK: - Helpers

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func seekBackward() {
        elapsedTime = max(0, elapsedTime - 15)
        progress = elapsedTime / meditation.duration
    }

    private func seekForward() {
        elapsedTime = min(meditation.duration, elapsedTime + 30)
        progress = elapsedTime / meditation.duration
    }
}
