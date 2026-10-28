import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Query private var users: [UserProfile]
    @State private var appeared = false

    private var user: UserProfile? { users.first }

    var body: some View {
        ZStack {
            AmbientBackground(style: .nightSky)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: DSSpacing.xl) {
                    header
                    profileSection
                    preferencesSection
                    subscriptionSection
                    aboutSection
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
        }
    }

    // MARK: - Header

    private var header: some View {
        Text("Settings")
            .font(DSFont.headlineLarge)
            .foregroundStyle(DSColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Profile

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            sectionTitle("Profile")

            GlassCard {
                VStack(spacing: DSSpacing.md) {
                    settingsRow(
                        icon: "person.circle",
                        title: "Name",
                        value: user?.name.isEmpty == false ? user!.name : "Not set"
                    )

                    Divider().opacity(0.1)

                    settingsRow(
                        icon: "envelope",
                        title: "Email",
                        value: user?.email.isEmpty == false ? user!.email : "Not set"
                    )
                }
            }
        }
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            sectionTitle("Sleep Preferences")

            GlassCard {
                VStack(spacing: DSSpacing.md) {
                    settingsRow(
                        icon: "moon.stars",
                        title: "Sleep Goal",
                        value: user?.sleepGoal.rawValue ?? "7-8 hours"
                    )

                    Divider().opacity(0.1)

                    settingsRow(
                        icon: "brain.head.profile",
                        title: "Sleep Challenge",
                        value: user?.sleepProblem.shortLabel ?? "Stress"
                    )

                    Divider().opacity(0.1)

                    settingsRow(
                        icon: "leaf",
                        title: "Preferred Mood",
                        value: user?.preferredMood.rawValue ?? "Calm & Still"
                    )
                }
            }
        }
    }

    // MARK: - Subscription

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            sectionTitle("Subscription")

            Button {
                DSHaptics.tap()
                appState.showPaywall = true
            } label: {
                GlassCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: DSSpacing.sm) {
                                Image(systemName: isPremium ? "crown.fill" : "crown")
                                    .foregroundStyle(DSColors.warmAmber)

                                Text(isPremium ? "Premium" : "Free Plan")
                                    .font(DSFont.bodyLarge)
                                    .foregroundStyle(DSColors.textPrimary)
                            }

                            Text(isPremium ? "All features unlocked" : "Upgrade for full access")
                                .font(DSFont.bodySmall)
                                .foregroundStyle(DSColors.textTertiary)
                        }

                        Spacer()

                        if !isPremium {
                            Text("Upgrade")
                                .font(DSFont.label)
                                .foregroundStyle(DSColors.moonGlow)
                                .padding(.horizontal, DSSpacing.md)
                                .padding(.vertical, DSSpacing.sm)
                                .liquidGlass(cornerRadius: DSRadius.pill, opacity: 0.5)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            sectionTitle("About")

            GlassCard {
                VStack(spacing: DSSpacing.md) {
                    settingsRow(icon: "info.circle", title: "Version", value: appVersion)
                    Divider().opacity(0.1)
                    settingsRow(icon: "heart", title: "Rate DreamScape", value: "")
                    Divider().opacity(0.1)
                    settingsRow(icon: "envelope", title: "Send Feedback", value: "")
                    Divider().opacity(0.1)
                    settingsRow(icon: "lock.shield", title: "Privacy Policy", value: "")
                }
            }
        }
    }

    // MARK: - Components

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(DSFont.label)
            .foregroundStyle(DSColors.textTertiary)
            .textCase(.uppercase)
            .tracking(1)
    }

    private func settingsRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(DSColors.moonGlow)
                .frame(width: 24)

            Text(title)
                .font(DSFont.bodyLarge)
                .foregroundStyle(DSColors.textPrimary)

            Spacer()

            Text(value)
                .font(DSFont.bodyMedium)
                .foregroundStyle(DSColors.textTertiary)
        }
    }

    // MARK: - Helpers

    private var isPremium: Bool {
        user?.subscriptionStatus == .premium
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
