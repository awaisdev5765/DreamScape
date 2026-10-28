import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var isLoading = false
    @State private var appeared = false

    private let store = StoreKitService.shared

    enum SubscriptionPlan {
        case monthly, yearly
    }

    var body: some View {
        ZStack {
            AmbientBackground(style: .aurora)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        DSHaptics.tap()
                        withAnimation(DSAnimation.gentle) {
                            appState.showPaywall = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundStyle(DSColors.textSecondary)
                            .frame(width: 36, height: 36)
                            .liquidGlass(cornerRadius: 18, opacity: 0.4)
                    }
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.top, DSSpacing.md)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DSSpacing.xxl) {
                        heroSection
                        featuresSection
                        plansSection
                        subscribeButton
                        legalSection
                    }
                    .padding(.horizontal, DSSpacing.xl)
                    .padding(.bottom, DSSpacing.xxl)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(DSAnimation.fadeIn) {
                appeared = true
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: DSSpacing.lg) {
            ZStack {
                BreathingCircle(size: 120, primaryColor: DSColors.warmAmber, secondaryColor: DSColors.lavenderMist)

                Image(systemName: "crown.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(DSColors.warmAmber)
            }

            VStack(spacing: DSSpacing.sm) {
                Text("Unlock\nDreamScape")
                    .font(DSFont.displaySmall)
                    .foregroundStyle(DSColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Your complete sleep sanctuary")
                    .font(DSFont.bodyMedium)
                    .foregroundStyle(DSColors.textSecondary)
            }
        }
        .padding(.top, DSSpacing.lg)
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(spacing: DSSpacing.md) {
            featureRow(icon: "moon.zzz.fill", title: "All Sleep Sounds", subtitle: "Unlimited ambient library")
            featureRow(icon: "waveform", title: "Premium Meditations", subtitle: "Exclusive guided sessions")
            featureRow(icon: "sparkle", title: "Advanced Insights", subtitle: "Deeper sleep intelligence")
            featureRow(icon: "book.closed.fill", title: "Sleep Stories", subtitle: "Narrated bedtime tales")
        }
    }

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(DSColors.moonGlow)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DSFont.bodyLarge)
                    .foregroundStyle(DSColors.textPrimary)

                Text(subtitle)
                    .font(DSFont.bodySmall)
                    .foregroundStyle(DSColors.textTertiary)
            }

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(DSColors.sleepGood)
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.vertical, DSSpacing.md)
        .liquidGlass(cornerRadius: DSRadius.md, opacity: 0.4)
    }

    // MARK: - Plans

    private var plansSection: some View {
        HStack(spacing: DSSpacing.md) {
            planCard(
                plan: .yearly,
                title: "Yearly",
                price: store.yearlyProduct?.displayPrice ?? "$39.99",
                subtitle: "Best value",
                badge: "SAVE 60%"
            )

            planCard(
                plan: .monthly,
                title: "Monthly",
                price: store.monthlyProduct?.displayPrice ?? "$7.99",
                subtitle: "per month",
                badge: nil
            )
        }
    }

    private func planCard(plan: SubscriptionPlan, title: String, price: String, subtitle: String, badge: String?) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            DSHaptics.selection()
            withAnimation(DSAnimation.gentle) {
                selectedPlan = plan
            }
        } label: {
            VStack(spacing: DSSpacing.sm) {
                if let badge {
                    Text(badge)
                        .font(DSFont.tag)
                        .foregroundStyle(DSColors.warmAmber)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, 3)
                        .background {
                            Capsule()
                                .fill(DSColors.warmAmber.opacity(0.15))
                        }
                } else {
                    Color.clear.frame(height: 20)
                }

                Text(title)
                    .font(DSFont.label)
                    .foregroundStyle(DSColors.textSecondary)

                Text(price)
                    .font(DSFont.headlineMedium)
                    .foregroundStyle(DSColors.textPrimary)

                Text(subtitle)
                    .font(DSFont.bodySmall)
                    .foregroundStyle(DSColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.lg)
            .liquidGlass(
                cornerRadius: DSRadius.lg,
                opacity: isSelected ? 0.8 : 0.4,
                borderOpacity: isSelected ? 1.0 : 0.3
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                        .stroke(DSColors.moonGlow.opacity(0.5), lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Subscribe Button

    private var subscribeButton: some View {
        Button {
            DSHaptics.tap()
            Task { await subscribe() }
        } label: {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Start Free Trial")
                        .font(DSFont.headlineSmall)
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [DSColors.moonGlow, DSColors.lavenderMist],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .clipShape(Capsule())
            .shadow(color: DSColors.moonGlow.opacity(0.4), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }

    // MARK: - Legal

    private var legalSection: some View {
        VStack(spacing: DSSpacing.sm) {
            Button("Restore Purchases") {
                Task { await store.restorePurchases() }
            }
            .font(DSFont.bodySmall)
            .foregroundStyle(DSColors.textTertiary)

            Text("Cancel anytime. Auto-renews unless cancelled 24 hours before the period ends.")
                .font(DSFont.bodySmall)
                .foregroundStyle(DSColors.textTertiary)
                .multilineTextAlignment(.center)

            HStack(spacing: DSSpacing.lg) {
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                Link("Terms of Use", destination: URL(string: "https://example.com/terms")!)
            }
            .font(DSFont.bodySmall)
            .foregroundStyle(DSColors.textTertiary)
        }
    }

    // MARK: - Actions

    private func subscribe() async {
        isLoading = true
        defer { isLoading = false }

        let product: Product? = selectedPlan == .yearly ? store.yearlyProduct : store.monthlyProduct
        guard let product else { return }

        do {
            let success = try await store.purchase(product)
            if success {
                DSHaptics.success()
                withAnimation(DSAnimation.gentle) {
                    appState.showPaywall = false
                }
            }
        } catch {
            print("Purchase error: \(error)")
        }
    }
}
