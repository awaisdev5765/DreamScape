import SwiftUI

enum DSFont {

    // MARK: - Display (Hero text, sleep scores)

    static let displayLarge = Font.system(size: 56, weight: .thin, design: .rounded)
    static let displayMedium = Font.system(size: 40, weight: .light, design: .rounded)
    static let displaySmall = Font.system(size: 32, weight: .light, design: .rounded)

    // MARK: - Headlines

    static let headlineLarge = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headlineMedium = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headlineSmall = Font.system(size: 18, weight: .semibold, design: .rounded)

    // MARK: - Body

    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .rounded)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .rounded)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .rounded)

    // MARK: - Captions & Labels

    static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
    static let label = Font.system(size: 14, weight: .medium, design: .rounded)
    static let tag = Font.system(size: 11, weight: .semibold, design: .rounded)
}

// MARK: - Text Styles

struct DSTextStyle: ViewModifier {
    enum Style {
        case hero
        case title
        case subtitle
        case body
        case secondary
        case insight
    }

    let style: Style

    func body(content: Content) -> some View {
        switch style {
        case .hero:
            content
                .font(DSFont.displayLarge)
                .foregroundStyle(DSColors.textPrimary)
                .tracking(-1)
        case .title:
            content
                .font(DSFont.headlineLarge)
                .foregroundStyle(DSColors.textPrimary)
        case .subtitle:
            content
                .font(DSFont.headlineSmall)
                .foregroundStyle(DSColors.textSecondary)
        case .body:
            content
                .font(DSFont.bodyLarge)
                .foregroundStyle(DSColors.textPrimary)
        case .secondary:
            content
                .font(DSFont.bodyMedium)
                .foregroundStyle(DSColors.textSecondary)
        case .insight:
            content
                .font(DSFont.bodyLarge)
                .foregroundStyle(DSColors.starlight)
                .italic()
        }
    }
}

extension View {
    func dsText(_ style: DSTextStyle.Style) -> some View {
        modifier(DSTextStyle(style: style))
    }
}
