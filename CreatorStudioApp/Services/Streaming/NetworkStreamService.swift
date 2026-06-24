import Combine
import Foundation

final class NetworkStreamService: ObservableObject {
    @Published var isStreaming = false
    @Published var streamURL: String = ""

    private var streamManager: StreamManager?

    func startStreaming(to url: String) {
        streamURL = url

        let components = url.components(separatedBy: ":")
        let host = components.first ?? "localhost"
        let port = UInt16(components.last ?? "8080") ?? 8080

        let manager = StreamManager(host: host, port: port)
        manager.connect()
        streamManager = manager
        isStreaming = true
    }

    func stopStreaming() {
        streamManager?.disconnect()
        streamManager = nil
        isStreaming = false
        streamURL = ""
    }

    var statistics: StreamStatistics {
        streamManager?.statistics ?? StreamStatistics()
    }

    var isConnected: Bool {
        streamManager?.isConnected ?? false
    }
}
