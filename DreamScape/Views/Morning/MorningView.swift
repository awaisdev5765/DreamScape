import SwiftUI
import SwiftData

struct MorningView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SleepLog.createdAt, order: .reverse) private var sleepLogs: [SleepLog]
    @Query private var users: [UserProfile]

    @State private var appeared = false
    @State private var selectedQuality: SleepQuality?
    @State private var showInsight = false
    @State private var insightText = ""

    private var latestLog: SleepLog? { sleepLogs.first }
    private var user: UserProfile? { users.first }

    var body: some View {
        ZStack {
            AmbientBackground(style: .nightSky)
                .ignoresSafeArea()

            VStack(spacing: DSSpacing.xxl) {
                Spacer()

                if !showInsight {
                    ratingContent
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    insightContent
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }

                Spacer()

                if showInsight {
                    doneButton
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, DSSpacing.xl)
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(DSAnimation.fadeIn) {
                appeared = true
            }
        }
    }

    // MARK: - Rating Content

    private var ratingContent: some View {
        VStack(spacing: DSSpacing.xxl) {
            // Sunrise icon
            Image(systemName: "sunrise.fill")
                .font(.system(size: 48))
                .foregroundStyle(DSColors.warmAmber)
                .ambientGlow(color: DSColors.warmAmber, radius: 25)

            VStack(spacing: DSSpacing.sm) {
                Text("Good morning")
                    .font(DSFont.displaySmall)
                    .foregroundStyle(DSColors.textPrimary)

                Text("How did you sleep?")
                    .font(DSFont.bodyLarge)
                    .foregroundStyle(DSColors.textSecondary)
            }

            // Quality buttons
            HStack(spacing: DSSpacing.lg) {
                ForEach(SleepQuality.allCases, id: \.rawValue) { quality in
                    qualityButton(quality)
                }
            }
        }
    }

    private func qualityButton(_ quality: SleepQuality) -> some View {
        Button {
            DSHaptics.gentle()
            withAnimation(DSAnimation.gentle) {
                selectedQuality = quality
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                submitRating(quality)
            }
        } label: {
            VStack(spacing: DSSpacing.md) {
                Text(quality.emoji)
                    .font(.system(size: 44))

                Text(quality.rawValue)
                    .font(DSFont.label)
                    .foregroundStyle(
                        selectedQuality == quality ? quality.color : DSColors.textSecondary
                    )
            }
            .frame(width: 90, height: 100)
            .liquidGlass(
                cornerRadius: DSRadius.lg,
                opacity: selectedQuality == quality ? 0.8 : 0.4
            )
            .overlay {
                if selectedQuality == quality {
                    RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                        .stroke(quality.color.opacity(0.5), lineWidth: 1)
                }
            }
            .scaleEffect(selectedQuality == quality ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(DSAnimation.gentle, value: selectedQuality)
    }

    // MARK: - Insight Content

    private var insightContent: some View {
        VStack(spacing: DSSpacing.xxl) {
            Image(systemName: "sparkle")
                .font(.system(size: 40))
                .foregroundStyle(DSColors.starlight)
                .ambientGlow(color: DSColors.starlight, radius: 20)

            VStack(spacing: DSSpacing.md) {
                if let log = latestLog {
                    Text("\(log.sleepScore)")
                        .font(DSFont.displayLarge)
                        .foregroundStyle(DSColors.textPrimary)

                    Text("Sleep Score")
                        .font(DSFont.caption)
                        .foregroundStyle(DSColors.textTertiary)
                        .textCase(.uppercase)
                        .tracking(1.5)
                }
            }

            GlassCard {
                HStack(spacing: DSSpacing.md) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(DSColors.warmAmber)

                    Text(insightText)
                        .font(DSFont.bodyMedium)
                        .foregroundStyle(DSColors.starlight)
                        .lineLimit(3)
                }
            }
        }
    }

    // MARK: - Done

    private var doneButton: some View {
        Button {
            DSHaptics.tap()
            appState.completeMorningCheck()
        } label: {
            Text("Start Your Day")
                .font(DSFont.headlineSmall)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background {
                    Capsule()
                        .fill(DSColors.warmAmber.opacity(0.25))
                }
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    Capsule()
                        .stroke(DSColors.warmAmber.opacity(0.3), lineWidth: 0.5)
                }
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.bottom, DSSpacing.xxl)
    }

    // MARK: - Actions

    private func submitRating(_ quality: SleepQuality) {
        guard let log = latestLog else {
            appState.completeMorningCheck()
            return
        }

        log.qualityRating = quality
        let hours = log.durationHours
        let bedtimeHour = log.bedtimeHour
        log.sleepScore = InsightsEngine.calculateScore(
            hours: hours,
            quality: quality,
            bedtimeHour: bedtimeHour
        )

        insightText = InsightsEngine.generateInsight(
            from: sleepLogs,
            problem: user?.sleepProblem ?? .stress
        )

        DSHaptics.success()
        withAnimation(DSAnimation.slow) {
            showInsight = true
        }
    }
}
