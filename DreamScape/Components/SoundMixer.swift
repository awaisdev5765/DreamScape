import SwiftUI

struct SoundMixerView: View {
    @Binding var selectedSound: AmbientSound
    @Binding var volume: Float

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            // Sound selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.md) {
                    ForEach(AmbientSound.allCases) { sound in
                        SoundChip(
                            sound: sound,
                            isSelected: selectedSound == sound
                        ) {
                            withAnimation(DSAnimation.gentle) {
                                selectedSound = sound
                            }
                            DSHaptics.selection()
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.lg)
            }

            // Volume slider
            HStack(spacing: DSSpacing.md) {
                Image(systemName: "speaker.fill")
                    .font(.caption)
                    .foregroundStyle(DSColors.textTertiary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 4)

                        Capsule()
                            .fill(DSColors.moonGlow.opacity(0.6))
                            .frame(width: geo.size.width * CGFloat(volume), height: 4)

                        Circle()
                            .fill(.white)
                            .frame(width: 16, height: 16)
                            .shadow(color: DSColors.moonGlow.opacity(0.4), radius: 6)
                            .offset(x: (geo.size.width - 16) * CGFloat(volume))
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let newVolume = Float(value.location.x / geo.size.width)
                                        volume = max(0, min(1, newVolume))
                                    }
                            )
                    }
                }
                .frame(height: 16)

                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
                    .foregroundStyle(DSColors.textTertiary)
            }
            .padding(.horizontal, DSSpacing.lg)
        }
    }
}

// MARK: - Sound Chip

struct SoundChip: View {
    let sound: AmbientSound
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DSSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(isSelected ? DSColors.moonGlow.opacity(0.2) : Color.white.opacity(0.05))
                        .frame(width: 56, height: 56)

                    Image(systemName: sound.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(isSelected ? DSColors.moonGlow : DSColors.textSecondary)
                }
                .overlay {
                    Circle()
                        .stroke(isSelected ? DSColors.moonGlow.opacity(0.4) : .clear, lineWidth: 1)
                }

                Text(sound.rawValue)
                    .font(DSFont.tag)
                    .foregroundStyle(isSelected ? DSColors.textPrimary : DSColors.textTertiary)
            }
        }
        .buttonStyle(.plain)
    }
}
