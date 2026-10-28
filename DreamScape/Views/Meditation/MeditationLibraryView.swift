import SwiftUI
import SwiftData

struct MeditationLibraryView: View {
    @Environment(AppState.self) private var appState
    @Query private var users: [UserProfile]
    @Query(sort: \Meditation.sortOrder) private var meditations: [Meditation]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedCategory: MeditationCategory?
    @State private var selectedMeditation: Meditation?
    @State private var appeared = false

    private var isPremium: Bool {
        users.first?.subscriptionStatus == .premium
    }

    private var filteredMeditations: [Meditation] {
        guard let category = selectedCategory else { return meditations }
        return meditations.filter { $0.category == category }
    }

    var body: some View {
        ZStack {
            AmbientBackground(style: .deepOcean)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: DSSpacing.xl) {
                    header
                    categoryFilter
                    meditationList
                }
                .padding(.top, DSSpacing.xxl)
                .padding(.bottom, 120)
            }

            if let meditation = selectedMeditation {
                MeditationPlayerView(
                    meditation: meditation,
                    onDismiss: {
                        withAnimation(DSAnimation.gentle) {
                            selectedMeditation = nil
                        }
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .zIndex(5)
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(DSAnimation.fadeIn) {
                appeared = true
            }
            seedMeditationsIfNeeded()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Meditate")
                .font(DSFont.headlineLarge)
                .foregroundStyle(DSColors.textPrimary)

            Text("Find your calm")
                .font(DSFont.bodyMedium)
                .foregroundStyle(DSColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DSSpacing.lg)
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.sm) {
                categoryChip(nil, label: "All")
                ForEach(MeditationCategory.allCases, id: \.rawValue) { category in
                    categoryChip(category, label: category.rawValue)
                }
            }
            .padding(.horizontal, DSSpacing.lg)
        }
    }

    private func categoryChip(_ category: MeditationCategory?, label: String) -> some View {
        let isActive = selectedCategory == category
        return Button {
            DSHaptics.selection()
            withAnimation(DSAnimation.gentle) {
                selectedCategory = category
            }
        } label: {
            Text(label)
                .font(DSFont.label)
                .foregroundStyle(isActive ? DSColors.textPrimary : DSColors.textTertiary)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.sm)
                .liquidGlass(
                    cornerRadius: DSRadius.pill,
                    opacity: isActive ? 0.7 : 0.3,
                    borderOpacity: isActive ? 0.8 : 0.3
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - List

    private var meditationList: some View {
        LazyVStack(spacing: DSSpacing.sm) {
            ForEach(filteredMeditations, id: \.id) { meditation in
                MeditationCard(
                    meditation: meditation,
                    isPremiumUser: isPremium
                ) {
                    if meditation.isPremium && !isPremium {
                        appState.showPaywall = true
                    } else {
                        withAnimation(DSAnimation.gentle) {
                            selectedMeditation = meditation
                        }
                    }
                }
            }
        }
        .padding(.horizontal, DSSpacing.lg)
    }

    // MARK: - Sample Data

    private func seedMeditationsIfNeeded() {
        guard meditations.isEmpty else { return }

        let items: [(String, String, MeditationCategory, TimeInterval, Bool)] = [
            ("Ocean Drift", "Drift away with gentle waves", .deepSleep, 600, false),
            ("Midnight Rain", "Rainfall on a quiet night", .deepSleep, 900, false),
            ("Starlight Lullaby", "A celestial sleep journey", .deepSleep, 1200, true),
            ("Release & Let Go", "Melt away tension", .anxietyRelief, 480, false),
            ("Safe Space", "Your sanctuary of calm", .anxietyRelief, 600, false),
            ("Inner Peace", "Deep relaxation meditation", .anxietyRelief, 900, true),
            ("Morning Clarity", "Start with intention", .focusCalm, 300, false),
            ("Mindful Moment", "A brief pause for presence", .focusCalm, 180, false),
            ("Deep Focus", "Enhance concentration", .focusCalm, 600, true),
            ("The Enchanted Forest", "A magical bedtime tale", .sleepStories, 1800, false),
            ("Journey to the Stars", "Travel through the cosmos", .sleepStories, 1500, true),
            ("The Gentle River", "Follow the water home", .sleepStories, 1200, true),
        ]

        for (index, item) in items.enumerated() {
            let meditation = Meditation(
                title: item.0,
                subtitle: item.1,
                category: item.2,
                duration: item.3,
                isPremium: item.4,
                sortOrder: index
            )
            modelContext.insert(meditation)
        }
    }
}
