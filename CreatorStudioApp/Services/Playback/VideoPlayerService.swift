import Combine
import AVFoundation
import UIKit

final class VideoPlayerService: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: CMTime = .zero
    @Published var duration: CMTime = .zero
    @Published var rate: Float = 1.0

    let player: AVPlayer
    private var timeObserver: Any?
    private var itemObserver: NSKeyValueObservation?

    override init() {
        player = AVPlayer()
        super.init()
        setupTimeObserver()
    }

    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time
        }
    }

    func load(url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)

        itemObserver = playerItem.observe(\.status) { [weak self] item, _ in
            if item.status == .readyToPlay {
                self?.duration = asset.duration
            }
        }
    }

    func play() {
        player.play()
        isPlaying = true
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func seek(to time: CMTime) {
        player.seek(to: time)
    }

    func seekToPercentage(_ percentage: Double) {
        let time = CMTimeMultiplyByFloat64(duration, multiplier: Float64(percentage / 100.0))
        seek(to: time)
    }

    func setRate(_ rate: Float) {
        self.rate = rate
        player.rate = rate
    }

    func skipForward(by seconds: Double = 10) {
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: seconds, preferredTimescale: 600))
        seek(to: newTime)
    }

    func skipBackward(by seconds: Double = 10) {
        let newTime = CMTimeSubtract(currentTime, CMTime(seconds: seconds, preferredTimescale: 600))
        seek(to: newTime)
    }

    var progress: Double {
        guard duration.seconds > 0 else { return 0 }
        return (currentTime.seconds / duration.seconds) * 100
    }

    var remainingTime: CMTime {
        CMTimeSubtract(duration, currentTime)
    }

    deinit {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
        }
        itemObserver?.invalidate()
    }
}
