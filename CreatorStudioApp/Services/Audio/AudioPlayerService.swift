import Combine
import AVFoundation

protocol AudioPlayerServiceDelegate: AnyObject {
    func audioPlayerServiceDidFinishPlaying(_ service: AudioPlayerService)
    func audioPlayerService(_ service: AudioPlayerService, didUpdateTime time: TimeInterval)
    func audioPlayerService(_ service: AudioPlayerService, didFailWith error: Error)
}

final class AudioPlayerService: NSObject, ObservableObject {
    weak var delegate: AudioPlayerServiceDelegate?

    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    private var player: AVAudioPlayer?
    private var timer: Timer?

    override init() {
        super.init()
    }

    func load(_ url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            duration = player?.duration ?? 0
            currentTime = 0
        } catch {
            delegate?.audioPlayerService(self, didFailWith: error)
        }
    }

    func play() {
        player?.play()
        isPlaying = true
        isPaused = false

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.currentTime = self.player?.currentTime ?? 0
            self.delegate?.audioPlayerService(self, didUpdateTime: self.currentTime)
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        isPaused = true
        timer?.invalidate()
        timer = nil
    }

    func stop() {
        player?.stop()
        player?.currentTime = 0
        isPlaying = false
        isPaused = false
        currentTime = 0
        timer?.invalidate()
        timer = nil
    }

    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
    }

    func setVolume(_ volume: Float) {
        player?.volume = volume
    }
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        isPaused = false
        timer?.invalidate()
        timer = nil
        delegate?.audioPlayerServiceDidFinishPlaying(self)
    }
}
