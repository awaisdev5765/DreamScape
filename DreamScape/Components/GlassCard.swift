import SwiftUI

struct GlassCard<Content: View>: View {
    var padding: CGFloat = DSSpacing.lg
    var cornerRadius: CGFloat = DSRadius.lg
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .liquidGlass(cornerRadius: cornerRadius)
    }
}

// MARK: - Selection Card (Onboarding)

struct SelectionCard: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: {
            DSHaptics.selection()
            action()
        }) {
            HStack(spacing: DSSpacing.md) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? DSColors.moonGlow : DSColors.textSecondary)
                    .frame(width: 32)

                Text(title)
                    .font(DSFont.bodyLarge)
                    .foregroundStyle(isSelected ? DSColors.textPrimary : DSColors.textSecondary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(DSColors.moonGlow)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.vertical, DSSpacing.md + 4)
            .liquidGlass(
                cornerRadius: DSRadius.md,
                opacity: isSelected ? 0.9 : 0.5,
                borderOpacity: isSelected ? 1.0 : 0.4
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
                        .stroke(DSColors.moonGlow.opacity(0.4), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(DSAnimation.gentle, value: isSelected)
    }
}

// MARK: - Meditation Card

struct MeditationCard: View {
    let meditation: Meditation
    let isPremiumUser: Bool
    var action: () -> Void

    private var isLocked: Bool {
        meditation.isPremium && !isPremiumUser
    }

    var body: some View {
        Button(action: {
            DSHaptics.tap()
            action()
        }) {
            HStack(spacing: DSSpacing.md) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: meditation.category.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: meditation.category.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(meditation.title)
                        .font(DSFont.bodyLarge)
                        .foregroundStyle(DSColors.textPrimary)
                        .lineLimit(1)

                    Text(meditation.formattedDuration)
                        .font(DSFont.caption)
                        .foregroundStyle(DSColors.textTertiary)
                }

                Spacer()

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(DSColors.warmAmber)
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(DSColors.moonGlow.opacity(0.8))
                }
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.vertical, DSSpacing.md)
            .liquidGlass(cornerRadius: DSRadius.md, opacity: 0.5)
        }
        .buttonStyle(.plain)
    }
}
