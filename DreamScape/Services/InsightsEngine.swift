import Foundation

enum InsightsEngine {

    // MARK: - Score Calculation

    static func calculateScore(hours: Double, quality: SleepQuality, bedtimeHour: Int) -> Int {
        var score: Double = 0

        // Duration component (40% weight)
        let durationScore: Double = switch hours {
        case 7...9: 100
        case 6..<7: 75
        case 9..<10: 80
        case 5..<6: 50
        default: 30
        }
        score += durationScore * 0.4

        // Quality component (35% weight)
        score += (quality.scoreMultiplier * 100) * 0.35

        // Bedtime consistency component (25% weight)
        let bedtimeScore: Double = switch bedtimeHour {
        case 21...23: 100
        case 0: 80
        case 20: 85
        case 1: 60
        default: 40
        }
        score += bedtimeScore * 0.25

        return max(0, min(100, Int(score)))
    }

    static func generateScore(from logs: [SleepLog]) -> Int {
        guard let latest = logs.first else { return 72 }
        let quality = latest.qualityRating ?? .okay
        return calculateScore(
            hours: latest.durationHours,
            quality: quality,
            bedtimeHour: latest.bedtimeHour
        )
    }

    // MARK: - Insight Generation (Rule-Based)

    static func generateInsight(from logs: [SleepLog], problem: SleepProblem) -> String {
        guard !logs.isEmpty else {
            return problemBasedDefaultInsight(problem)
        }

        let recentLogs = Array(logs.prefix(7))

        // Check bedtime pattern
        if let bedtimeInsight = bedtimeInsight(recentLogs) {
            return bedtimeInsight
        }

        // Check duration trend
        if let durationInsight = durationInsight(recentLogs) {
            return durationInsight
        }

        // Check consistency
        if let consistencyInsight = consistencyInsight(recentLogs) {
            return consistencyInsight
        }

        return problemBasedDefaultInsight(problem)
    }

    // MARK: - Pattern Detection

    private static func bedtimeInsight(_ logs: [SleepLog]) -> String? {
        guard logs.count >= 3 else { return nil }

        let bedtimes = logs.map { $0.bedtimeHour }
        let goodNights = logs.filter { $0.qualityRating == .good }

        if let bestBedtime = goodNights.first?.bedtimeHour {
            let hour = bestBedtime > 12 ? bestBedtime : bestBedtime + 12
            let formatted = "\(hour > 12 ? hour - 12 : hour):\(String(format: "%02d", 0)) \(hour >= 12 ? "AM" : "PM")"
            return "Your sleep improves when you're in bed by \(formatted)."
        }

        let avgBedtime = bedtimes.reduce(0, +) / bedtimes.count
        if avgBedtime > 0 && avgBedtime < 4 {
            return "Try sleeping 30 minutes earlier tonight."
        }

        return nil
    }

    private static func durationInsight(_ logs: [SleepLog]) -> String? {
        guard logs.count >= 2 else { return nil }

        let durations = logs.map { $0.durationHours }
        let avg = durations.reduce(0, +) / Double(durations.count)

        if avg < 6.5 {
            return "You're averaging \(String(format: "%.1f", avg)) hours. An extra 30 minutes could make a big difference."
        }

        if avg >= 7.5 {
            return "Great consistency — you're averaging \(String(format: "%.1f", avg)) hours of sleep."
        }

        let trend = durations.first! - durations.last!
        if trend > 0.5 {
            return "Your sleep duration is improving. Keep it up."
        } else if trend < -0.5 {
            return "Your sleep has been shorter lately. Wind down a bit earlier tonight."
        }

        return nil
    }

    private static func consistencyInsight(_ logs: [SleepLog]) -> String? {
        guard logs.count >= 4 else { return nil }

        let bedtimes = logs.map { $0.bedtimeHour }
        let spread = (bedtimes.max() ?? 0) - (bedtimes.min() ?? 0)

        if spread <= 1 {
            return "Your sleep schedule is very consistent. This helps your body's natural rhythm."
        }

        if spread >= 3 {
            return "Your bedtime varies by \(spread) hours. A more consistent schedule can help."
        }

        return nil
    }

    private static func problemBasedDefaultInsight(_ problem: SleepProblem) -> String {
        switch problem {
        case .stress:
            [
                "Try a 5-minute breathing exercise before bed tonight.",
                "Writing down tomorrow's tasks can quiet a busy mind.",
                "A warm routine signals your body it's time to rest."
            ].randomElement()!
        case .insomnia:
            [
                "If you can't sleep after 20 minutes, get up and do something calm.",
                "Keep your room cool — around 65°F is ideal for sleep.",
                "Avoid screens 30 minutes before bed for better melatonin production."
            ].randomElement()!
        case .lateSleep:
            [
                "Set a gentle alarm 30 minutes before your target bedtime.",
                "Dimming lights an hour before bed helps shift your body clock.",
                "Start winding down earlier — even 15 minutes makes a difference."
            ].randomElement()!
        case .wakeUps:
            [
                "Avoid caffeine after 2 PM to reduce nighttime awakenings.",
                "A consistent sleep schedule trains your body to sleep through.",
                "Keep your room dark — even small light sources can disrupt sleep."
            ].randomElement()!
        }
    }
}
