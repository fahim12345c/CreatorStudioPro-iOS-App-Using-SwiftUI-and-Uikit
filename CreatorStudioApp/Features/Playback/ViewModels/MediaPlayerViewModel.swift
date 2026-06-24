import SwiftUI
import Combine
import AVFoundation

@MainActor
final class MediaPlayerViewModel: ObservableObject {
    let videoPlayerService = VideoPlayerService()
    let audioPlayerService = AudioPlayerService()

    @Published var currentMediaURL: URL?
    @Published var mediaType: MediaType = .video
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        audioPlayerService.$currentTime.assign(to: &$currentTime)
        videoPlayerService.$currentTime.map(\.seconds).assign(to: &$currentTime)

        audioPlayerService.$isPlaying.assign(to: &$isPlaying)
        videoPlayerService.$isPlaying.assign(to: &$isPlaying)

        audioPlayerService.$duration.assign(to: &$duration)
        videoPlayerService.$duration.map(\.seconds).assign(to: &$duration)
    }

    func loadVideo(_ url: URL) {
        mediaType = .video
        currentMediaURL = url
        currentTime = 0
        duration = 0
        videoPlayerService.load(url: url)
    }

    func loadAudio(_ url: URL) {
        mediaType = .audio
        currentMediaURL = url
        currentTime = 0
        duration = 0
        audioPlayerService.load(url)
    }

    func play() {
        switch mediaType {
        case .video:
            videoPlayerService.play()
        case .audio:
            audioPlayerService.play()
        default:
            break
        }
    }

    func pause() {
        switch mediaType {
        case .video:
            videoPlayerService.pause()
        case .audio:
            audioPlayerService.pause()
        default:
            break
        }
    }

    func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        switch mediaType {
        case .video:
            videoPlayerService.seek(to: cmTime)
        case .audio:
            audioPlayerService.seek(to: time)
        default:
            break
        }
    }

    func skipForward() {
        let newTime = min(currentTime + 10, duration)
        seek(to: newTime)
    }

    func skipBackward() {
        let newTime = max(currentTime - 10, 0)
        seek(to: newTime)
    }
}
