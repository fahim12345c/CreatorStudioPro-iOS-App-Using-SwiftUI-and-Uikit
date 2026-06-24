import SwiftUI
import Combine

@MainActor
final class StreamingViewModel: ObservableObject {
    let networkService = NetworkStreamService()

    @Published var isStreaming = false
    @Published var streamURL = ""
    @Published var fps: Double = 0
    @Published var bitrate: Double = 0
    @Published var droppedFrames: Int = 0
    @Published var totalFrames: Int = 0
    @Published var isConnected = false
    @Published var uptime: TimeInterval = 0
    @Published var showDebug = false

    var statistics: StreamStatistics {
        networkService.statistics
    }

    func startStreaming() {
        guard !streamURL.isEmpty else { return }
        networkService.startStreaming(to: streamURL)
        isStreaming = true
    }

    func stopStreaming() {
        networkService.stopStreaming()
        isStreaming = false
        isConnected = false
    }
}
