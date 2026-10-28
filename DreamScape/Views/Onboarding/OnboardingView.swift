import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @State private var appeared = false

    var body: some View {
        ZStack {
            AmbientBackground(style: .aurora)

            StarfieldView(starCount: 60)
                .opacity(0.5)

            VStack(spacing: 0) {
                Spacer()

                // Content
                TabView(selection: $currentPage) {
                    sleepGoalPage.tag(0)
                    sleepProblemPage.tag(1)
                    moodPage.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(DSAnimation.gentle, value: currentPage)

                Spacer()

                // Progress + Button
                VStack(spacing: DSSpacing.xl) {
                    progressDots

                    continueButton
                }
                .padding(.horizontal, DSSpacing.xl)
                .padding(.bottom, DSSpacing.xxl)
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(DSAnimation.fadeIn) {
                appeared = true
            }
        }
    }

    // MARK: - Page 1: Sleep Goal

    private var sleepGoalPage: some View {
        VStack(spacing: DSSpacing.xl) {
            pageHeader(
                icon: "moon.stars",
                title: "Your ideal\nsleep",
                subtitle: "How much sleep makes you feel your best?"
            )

            VStack(spacing: DSSpacing.sm) {
                ForEach(SleepGoal.allCases, id: \.rawValue) { goal in
                    SelectionCard(
                        icon: goal.icon,
                        title: goal.rawValue,
                        isSelected: appState.selectedSleepGoal == goal
                    ) {
                        appState.selectedSleepGoal = goal
                    }
                }
            }
            .padding(.horizontal, DSSpacing.xl)
        }
    }

    // MARK: - Page 2: Sleep Problem

    private var sleepProblemPage: some View {
        VStack(spacing: DSSpacing.xl) {
            pageHeader(
                icon: "heart",
                title: "What keeps\nyou up?",
                subtitle: "We'll personalize your experience"
            )

            VStack(spacing: DSSpacing.sm) {
                ForEach(SleepProblem.allCases, id: \.rawValue) { problem in
                    SelectionCard(
                        icon: problem.icon,
                        title: problem.rawValue,
                        isSelected: appState.selectedSleepProblem == problem
                    ) {
                        appState.selectedSleepProblem = problem
                    }
                }
            }
            .padding(.horizontal, DSSpacing.xl)
        }
    }

    // MARK: - Page 3: Preferred Mood

    private var moodPage: some View {
        VStack(spacing: DSSpacing.xl) {
            pageHeader(
                icon: "sparkles",
                title: "Your calming\nstyle",
                subtitle: "Choose what soothes you"
            )

            VStack(spacing: DSSpacing.sm) {
                ForEach(PreferredMood.allCases, id: \.rawValue) { mood in
                    SelectionCard(
                        icon: mood.icon,
                        title: mood.rawValue,
                        isSelected: appState.selectedMood == mood
                    ) {
                        appState.selectedMood = mood
                    }
                }
            }
            .padding(.horizontal, DSSpacing.xl)
        }
    }

    // MARK: - Shared Components

    private func pageHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(DSColors.moonGlow)
                .ambientGlow(color: DSColors.moonGlow, radius: 20)

            Text(title)
                .font(DSFont.displaySmall)
                .foregroundStyle(DSColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(DSFont.bodyMedium)
                .foregroundStyle(DSColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, DSSpacing.md)
    }

    private var progressDots: some View {
        HStack(spacing: DSSpacing.sm) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? DSColors.moonGlow : Color.white.opacity(0.2))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(DSAnimation.gentle, value: currentPage)
            }
        }
    }

    private var continueButton: some View {
        Button {
            DSHaptics.tap()
            if currentPage < 2 {
                withAnimation(DSAnimation.gentle) {
                    currentPage += 1
                }
            } else {
                completeOnboarding()
            }
        } label: {
            Text(currentPage < 2 ? "Continue" : "Begin Your Journey")
                .font(DSFont.headlineSmall)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background {
                    Capsule()
                        .fill(DSColors.moonGlow.opacity(0.25))
                }
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    Capsule()
                        .stroke(DSColors.moonGlow.opacity(0.4), lineWidth: 0.5)
                }
                .clipShape(Capsule())
                .shadow(color: DSColors.moonGlow.opacity(0.3), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func completeOnboarding() {
        let user = UserProfile(
            sleepGoal: appState.selectedSleepGoal,
            sleepProblem: appState.selectedSleepProblem,
            preferredMood: appState.selectedMood,
            hasCompletedOnboarding: true
        )
        modelContext.insert(user)
        DSHaptics.success()
        appState.completeOnboarding()
    }
}
