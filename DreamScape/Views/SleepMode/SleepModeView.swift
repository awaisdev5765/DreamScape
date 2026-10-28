import SwiftUI

struct SleepModeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var phase: SleepPhase = .windDown
    @State private var elapsedTime: TimeInterval = 0
    @State private var showControls = true
    @State private var controlsTimer: Timer?
    @State private var screenBrightness: CGFloat = 1.0
    @State private var breathLabel = "Breathe in..."

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum SleepPhase {
        case windDown
        case breathing
        case sleeping
    }

    var body: some View {
        ZStack {
            // Full immersive background
            AmbientBackground(style: .sleepMode)
                .ignoresSafeArea()

            FloatingParticles(count: 15, color: DSColors.moonGlow.opacity(0.3))
                .ignoresSafeArea()

            // Main content
            VStack(spacing: 0) {
                if showControls {
                    topBar
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()

                centerContent

                Spacer()

                if showControls {
                    bottomControls
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.vertical, DSSpacing.xl)
        }
        .statusBarHidden(phase == .sleeping)
        .onReceive(timer) { _ in
            elapsedTime += 1
            updateBreathLabel()
        }
        .onTapGesture {
            withAnimation(DSAnimation.gentle) {
                showControls.toggle()
            }
            scheduleAutoHide()
        }
        .onAppear {
            scheduleAutoHide()
            dimScreen()
        }
        .onDisappear {
            restoreScreen()
            controlsTimer?.invalidate()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                DSHaptics.gentle()
                endSession()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
                    .foregroundStyle(DSColors.textSecondary)
                    .frame(width: 40, height: 40)
                    .liquidGlass(cornerRadius: 20, opacity: 0.4)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(formattedElapsed)
                    .font(DSFont.label)
                    .foregroundStyle(DSColors.textSecondary)
                    .monospacedDigit()

                Text(phaseLabel)
                    .font(DSFont.tag)
                    .foregroundStyle(DSColors.textTertiary)
                    .textCase(.uppercase)
                    .tracking(1)
            }

            Spacer()

            Button {
                DSHaptics.gentle()
                withAnimation(DSAnimation.slow) {
                    advancePhase()
                }
            } label: {
                Image(systemName: phaseActionIcon)
                    .font(.body.weight(.medium))
                    .foregroundStyle(DSColors.moonGlow)
                    .frame(width: 40, height: 40)
                    .liquidGlass(cornerRadius: 20, opacity: 0.4)
            }
        }
    }

    // MARK: - Center Content

    private var centerContent: some View {
        VStack(spacing: DSSpacing.xl) {
            switch phase {
            case .windDown:
                windDownContent
            case .breathing:
                breathingContent
            case .sleeping:
                sleepingContent
            }
        }
        .animation(DSAnimation.slow, value: phase)
    }

    private var windDownContent: some View {
        VStack(spacing: DSSpacing.xl) {
            BreathingCircle(size: 200, isActive: true)

            VStack(spacing: DSSpacing.sm) {
                Text("Wind Down")
                    .font(DSFont.headlineLarge)
                    .foregroundStyle(DSColors.textPrimary)

                Text("Let your thoughts settle")
                    .font(DSFont.bodyMedium)
                    .foregroundStyle(DSColors.textSecondary)
            }
        }
    }

    private var breathingContent: some View {
        VStack(spacing: DSSpacing.xl) {
            BreathingCircle(
                size: 260,
                primaryColor: DSColors.lavenderMist,
                secondaryColor: DSColors.softCyan,
                isActive: true
            )

            Text(breathLabel)
                .font(DSFont.headlineMedium)
                .foregroundStyle(DSColors.starlight)
                .contentTransition(.opacity)
                .animation(DSAnimation.gentle, value: breathLabel)
        }
    }

    private var sleepingContent: some View {
        VStack(spacing: DSSpacing.lg) {
            BreathingCircle(
                size: 140,
                primaryColor: DSColors.moonGlow.opacity(0.5),
                secondaryColor: DSColors.cosmicBlue,
                isActive: true
            )
            .opacity(0.6)

            Text("Sleep well")
                .font(DSFont.headlineMedium)
                .foregroundStyle(DSColors.textTertiary)
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: DSSpacing.lg) {
            SoundMixerView(
                selectedSound: Binding(
                    get: { appState.selectedAmbientSound },
                    set: { appState.selectedAmbientSound = $0 }
                ),
                volume: Binding(
                    get: { appState.ambientVolume },
                    set: { appState.ambientVolume = $0 }
                )
            )

            // Phase buttons
            HStack(spacing: DSSpacing.md) {
                phaseButton("Wind Down", icon: "leaf", isActive: phase == .windDown) {
                    phase = .windDown
                }
                phaseButton("Breathe", icon: "wind", isActive: phase == .breathing) {
                    phase = .breathing
                }
                phaseButton("Sleep", icon: "moon.zzz", isActive: phase == .sleeping) {
                    phase = .sleeping
                }
            }

            // End session
            Button {
                DSHaptics.gentle()
                endSession()
            } label: {
                Text("End Session")
                    .font(DSFont.label)
                    .foregroundStyle(DSColors.textTertiary)
            }
        }
        .padding(.bottom, DSSpacing.md)
    }

    private func phaseButton(_ title: String, icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button {
            DSHaptics.selection()
            withAnimation(DSAnimation.gentle) {
                action()
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(DSFont.tag)
            }
            .foregroundStyle(isActive ? DSColors.moonGlow : DSColors.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.md)
            .liquidGlass(cornerRadius: DSRadius.md, opacity: isActive ? 0.7 : 0.3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var formattedElapsed: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var phaseLabel: String {
        switch phase {
        case .windDown: "Winding down"
        case .breathing: "Breathing"
        case .sleeping: "Sleeping"
        }
    }

    private var phaseActionIcon: String {
        switch phase {
        case .windDown: "wind"
        case .breathing: "moon.zzz"
        case .sleeping: "sunrise"
        }
    }

    private func advancePhase() {
        switch phase {
        case .windDown: phase = .breathing
        case .breathing: phase = .sleeping
        case .sleeping: endSession()
        }
    }

    private func updateBreathLabel() {
        let cycle = Int(elapsedTime) % 8
        if cycle < 4 {
            if breathLabel != "Breathe in..." {
                breathLabel = "Breathe in..."
                DSHaptics.breatheIn()
            }
        } else {
            if breathLabel != "Breathe out..." {
                breathLabel = "Breathe out..."
                DSHaptics.breatheOut()
            }
        }
    }

    private func scheduleAutoHide() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            withAnimation(DSAnimation.gentle) {
                showControls = false
            }
        }
    }

    private func dimScreen() {
        screenBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = 0.1
    }

    private func restoreScreen() {
        UIScreen.main.brightness = screenBrightness
    }

    private func endSession() {
        guard let start = appState.activeSleepStart else {
            appState.endSleepMode()
            return
        }

        let duration = Date.now.timeIntervalSince(start)
        let log = SleepLog(
            sleepStart: start,
            sleepEnd: .now,
            duration: duration
        )
        modelContext.insert(log)
        restoreScreen()
        appState.endSleepMode()
    }
}
