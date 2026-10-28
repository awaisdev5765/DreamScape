import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SleepLog.createdAt, order: .reverse) private var sleepLogs: [SleepLog]
    @Query private var users: [UserProfile]

    @State private var appeared = false
    @State private var showInsight = false
    @State private var currentTime = Date()

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var latestLog: SleepLog? { sleepLogs.first }
    private var user: UserProfile? { users.first }

    private var sleepScore: Int {
        latestLog?.sleepScore ?? InsightsEngine.generateScore(from: sleepLogs)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: currentTime)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Time to rest"
        }
    }

    private var insight: String {
        InsightsEngine.generateInsight(from: sleepLogs, problem: user?.sleepProblem ?? .stress)
    }

    var body: some View {
        ZStack {
            AmbientBackground(style: .nightSky)
            StarfieldView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: DSSpacing.xxl) {
                    headerSection
                    scoreSection
                    insightSection
                    windDownButton
                    recentSleepSection
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.top, DSSpacing.xxl)
                .padding(.bottom, 120)
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(DSAnimation.fadeIn) {
                appeared = true
            }
            withAnimation(DSAnimation.slow.delay(0.5)) {
                showInsight = true
            }
            seedSampleDataIfNeeded()
        }
        .onReceive(timer) { time in
            currentTime = time
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(greeting)
                .font(DSFont.headlineMedium)
                .foregroundStyle(DSColors.textSecondary)

            if let name = user?.name, !name.isEmpty {
                Text(name)
                    .font(DSFont.headlineLarge)
                    .foregroundStyle(DSColors.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DSSpacing.md)
    }

    // MARK: - Sleep Score

    private var scoreSection: some View {
        VStack(spacing: DSSpacing.lg) {
            SleepScoreRing(score: sleepScore, size: 200, lineWidth: 10)
                .ambientGlow(color: DSColors.moonGlow, radius: 30)

            if let log = latestLog {
                HStack(spacing: DSSpacing.xl) {
                    sleepStat(label: "BEDTIME", value: log.formattedBedtime, icon: "moon")
                    sleepStat(label: "DURATION", value: log.formattedDuration, icon: "clock")
                    sleepStat(label: "QUALITY", value: log.qualityRating?.rawValue ?? "—", icon: "heart")
                }
            }
        }
        .padding(.vertical, DSSpacing.lg)
    }

    private func sleepStat(label: String, value: String, icon: String) -> some View {
        VStack(spacing: DSSpacing.xs) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(DSColors.textTertiary)

            Text(value)
                .font(DSFont.bodyLarge)
                .foregroundStyle(DSColors.textPrimary)

            Text(label)
                .font(DSFont.tag)
                .foregroundStyle(DSColors.textTertiary)
                .tracking(1)
        }
    }

    // MARK: - Insight

    private var insightSection: some View {
        GlassCard {
            HStack(spacing: DSSpacing.md) {
                Image(systemName: "sparkle")
                    .font(.title3)
                    .foregroundStyle(DSColors.starlight)

                Text(insight)
                    .font(DSFont.bodyMedium)
                    .foregroundStyle(DSColors.starlight)
                    .lineLimit(2)
            }
        }
        .opacity(showInsight ? 1 : 0)
        .offset(y: showInsight ? 0 : 10)
    }

    // MARK: - Wind Down Button

    private var windDownButton: some View {
        Button {
            DSHaptics.gentle()
            appState.startSleepMode()
        } label: {
            HStack(spacing: DSSpacing.md) {
                Image(systemName: "moon.zzz.fill")
                    .font(.title2)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Start Wind Down")
                        .font(DSFont.headlineSmall)
                        .foregroundStyle(.white)

                    Text("Begin your nightly ritual")
                        .font(DSFont.bodySmall)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(DSSpacing.lg)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [DSColors.moonGlow.opacity(0.3), DSColors.lavenderMist.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
            }
            .overlay {
                Capsule()
                    .stroke(DSColors.moonGlow.opacity(0.3), lineWidth: 0.5)
            }
            .clipShape(Capsule())
            .shadow(color: DSColors.moonGlow.opacity(0.25), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recent Sleep

    private var recentSleepSection: some View {
        Group {
            if sleepLogs.count > 1 {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Recent nights")
                        .font(DSFont.label)
                        .foregroundStyle(DSColors.textTertiary)
                        .textCase(.uppercase)
                        .tracking(1)

                    VStack(spacing: DSSpacing.sm) {
                        ForEach(sleepLogs.prefix(5), id: \.id) { log in
                            recentSleepRow(log)
                        }
                    }
                }
            }
        }
    }

    private func recentSleepRow(_ log: SleepLog) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(log.createdAt.formatted(.dateTime.weekday(.wide)))
                    .font(DSFont.bodyMedium)
                    .foregroundStyle(DSColors.textPrimary)

                Text(log.formattedDuration)
                    .font(DSFont.bodySmall)
                    .foregroundStyle(DSColors.textTertiary)
            }

            Spacer()

            if let quality = log.qualityRating {
                Text(quality.emoji)
                    .font(.title3)
            }

            Text("\(log.sleepScore)")
                .font(DSFont.headlineSmall)
                .foregroundStyle(DSColors.moonGlow)
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.vertical, DSSpacing.md)
        .liquidGlass(cornerRadius: DSRadius.md, opacity: 0.4)
    }

    // MARK: - Sample Data

    private func seedSampleDataIfNeeded() {
        guard sleepLogs.isEmpty else { return }

        let calendar = Calendar.current
        let sampleData: [(Int, SleepQuality, Double)] = [
            (-1, .good, 7.5),
            (-2, .okay, 6.2),
            (-3, .good, 8.0),
            (-4, .bad, 5.5),
            (-5, .okay, 7.0)
        ]

        for (dayOffset, quality, hours) in sampleData {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: .now) else { continue }
            var bedtime = calendar.date(bySettingHour: 23, minute: Int.random(in: 0...45), second: 0, of: date) ?? date
            if dayOffset == -4 { bedtime = calendar.date(bySettingHour: 1, minute: 30, second: 0, of: date) ?? date }

            let log = SleepLog(
                sleepStart: bedtime,
                sleepEnd: bedtime.addingTimeInterval(hours * 3600),
                duration: hours * 3600,
                qualityRating: quality,
                sleepScore: InsightsEngine.calculateScore(hours: hours, quality: quality, bedtimeHour: calendar.component(.hour, from: bedtime))
            )
            modelContext.insert(log)
        }
    }
}
