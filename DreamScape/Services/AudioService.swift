import AVFoundation
import Observation

@MainActor @Observable
final class AudioService {
    static let shared = AudioService()

    var isPlaying = false
    var currentSound: AmbientSound?
    var volume: Float = 0.7 {
        didSet { ambientPlayer?.volume = volume }
    }

    private var ambientPlayer: AVAudioPlayer?
    private var meditationPlayer: AVAudioPlayer?

    private init() {
        configureAudioSession()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    // MARK: - Ambient Sounds

    func playAmbient(_ sound: AmbientSound) {
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "mp3") else {
            print("Audio file not found: \(sound.fileName)")
            return
        }

        do {
            ambientPlayer?.stop()
            ambientPlayer = try AVAudioPlayer(contentsOf: url)
            ambientPlayer?.numberOfLoops = -1
            ambientPlayer?.volume = volume
            ambientPlayer?.prepareToPlay()
            ambientPlayer?.play()
            currentSound = sound
            isPlaying = true
        } catch {
            print("Playback error: \(error)")
        }
    }

    func stopAmbient() {
        ambientPlayer?.stop()
        ambientPlayer = nil
        currentSound = nil
        isPlaying = false
    }

    // MARK: - Meditation Audio

    func playMeditation(url: URL, completion: @escaping () -> Void) {
        do {
            meditationPlayer?.stop()
            meditationPlayer = try AVAudioPlayer(contentsOf: url)
            meditationPlayer?.volume = 1.0
            meditationPlayer?.prepareToPlay()
            meditationPlayer?.play()
        } catch {
            print("Meditation playback error: \(error)")
        }
    }

    func stopMeditation() {
        meditationPlayer?.stop()
        meditationPlayer = nil
    }

    func pauseMeditation() {
        meditationPlayer?.pause()
    }

    func resumeMeditation() {
        meditationPlayer?.play()
    }

    // MARK: - Fade

    func fadeOut(duration: TimeInterval = 2.0) {
        guard let player = ambientPlayer else { return }
        let steps = 20
        let interval = duration / Double(steps)
        let volumeStep = player.volume / Float(steps)

        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) { [weak self] in
                player.volume -= volumeStep
                if i == steps - 1 {
                    self?.stopAmbient()
                }
            }
        }
    }
}
