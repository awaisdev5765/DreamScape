import SwiftUI

struct SleepScoreRing: View {
    var score: Int
    var size: CGFloat = 180
    var lineWidth: CGFloat = 8
    var showLabel: Bool = true

    @State private var animatedProgress: CGFloat = 0
    @State private var glowPulse = false

    private var progress: CGFloat {
        CGFloat(score) / 100.0
    }

    private var scoreColor: Color {
        switch score {
        case 80...100: DSColors.sleepGood
        case 60..<80: DSColors.moonGlow
        case 40..<60: DSColors.sleepOkay
        default: DSColors.sleepBad
        }
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.06), lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Score arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [scoreColor.opacity(0.4), scoreColor, scoreColor.opacity(0.8)],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * Double(animatedProgress))
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .shadow(color: scoreColor.opacity(glowPulse ? 0.5 : 0.25), radius: 12, x: 0, y: 0)

            // Score text
            if showLabel {
                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(DSFont.displayLarge)
                        .foregroundStyle(DSColors.textPrimary)
                        .contentTransition(.numericText())

                    Text("Sleep Score")
                        .font(DSFont.caption)
                        .foregroundStyle(DSColors.textTertiary)
                        .textCase(.uppercase)
                        .tracking(1.5)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                animatedProgress = progress
            }
            withAnimation(DSAnimation.breathing) {
                glowPulse = true
            }
        }
        .onChange(of: score) {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = progress
            }
        }
    }
}
