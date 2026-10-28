import Foundation
import SwiftData

@Model
final class Meditation {
    var id: String
    var title: String
    var subtitle: String
    var audioUrl: String
    var category: MeditationCategory
    var duration: TimeInterval
    var isPremium: Bool
    var artworkName: String
    var sortOrder: Int

    init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String = "",
        audioUrl: String = "",
        category: MeditationCategory,
        duration: TimeInterval,
        isPremium: Bool = false,
        artworkName: String = "",
        sortOrder: Int = 0
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.audioUrl = audioUrl
        self.category = category
        self.duration = duration
        self.isPremium = isPremium
        self.artworkName = artworkName
        self.sortOrder = sortOrder
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

// MARK: - Categories

enum MeditationCategory: String, Codable, CaseIterable {
    case deepSleep = "Deep Sleep"
    case anxietyRelief = "Anxiety Relief"
    case focusCalm = "Focus Calm"
    case sleepStories = "Sleep Stories"

    var icon: String {
        switch self {
        case .deepSleep: "moon.zzz"
        case .anxietyRelief: "heart.circle"
        case .focusCalm: "brain"
        case .sleepStories: "book.closed"
        }
    }

    var gradient: [SwiftUI.Color] {
        switch self {
        case .deepSleep: [DSColors.moonGlow, DSColors.cosmicBlue]
        case .anxietyRelief: [DSColors.lavenderMist, DSColors.nebula]
        case .focusCalm: [DSColors.softCyan, DSColors.aurora]
        case .sleepStories: [DSColors.warmAmber, DSColors.twilight]
        }
    }
}

import SwiftUI

// MARK: - Ambient Sound

enum AmbientSound: String, CaseIterable, Identifiable {
    case rain = "Rain"
    case ocean = "Ocean"
    case forest = "Forest"
    case wind = "Wind"
    case fireplace = "Fireplace"
    case whiteNoise = "White Noise"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .rain: "cloud.rain.fill"
        case .ocean: "water.waves"
        case .forest: "tree.fill"
        case .wind: "wind"
        case .fireplace: "flame.fill"
        case .whiteNoise: "waveform"
        }
    }

    var fileName: String {
        rawValue.lowercased().replacingOccurrences(of: " ", with: "_")
    }
}
