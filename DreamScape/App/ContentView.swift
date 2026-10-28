import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [UserProfile]

    var body: some View {
        ZStack {
            DSColors.midnight.ignoresSafeArea()

            if appState.isOnboarding && users.isEmpty {
                OnboardingView()
                    .transition(.opacity.combined(with: .scale(scale: 1.05)))
            } else {
                mainTabView
                    .transition(.opacity)
            }

            if appState.showSleepMode {
                SleepModeView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
                    .zIndex(10)
            }

            if appState.showMorningCheck {
                MorningView()
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .zIndex(11)
            }

            if appState.showPaywall {
                SubscriptionView()
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .zIndex(12)
            }
        }
        .animation(DSAnimation.slow, value: appState.isOnboarding)
        .animation(DSAnimation.slow, value: appState.showSleepMode)
        .animation(DSAnimation.gentle, value: appState.showMorningCheck)
        .onAppear {
            if !users.isEmpty {
                appState.isOnboarding = false
            }
        }
    }

    // MARK: - Main Tab View

    private var mainTabView: some View {
        TabView(selection: Bindable(appState).currentTab) {
            HomeView()
                .tabItem {
                    Label(AppTab.home.rawValue, systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)

            MeditationLibraryView()
                .tabItem {
                    Label(AppTab.meditate.rawValue, systemImage: AppTab.meditate.icon)
                }
                .tag(AppTab.meditate)

            SettingsView()
                .tabItem {
                    Label(AppTab.settings.rawValue, systemImage: AppTab.settings.icon)
                }
                .tag(AppTab.settings)
        }
        .tint(DSColors.moonGlow)
    }
}
