import Combine
import Foundation
import Network
import AVFoundation

protocol StreamManagerDelegate: AnyObject {
    func streamManagerDidConnect(_ manager: StreamManager)
    func streamManagerDidDisconnect(_ manager: StreamManager, error: Error?)
    func streamManager(_ manager: StreamManager, didUpdateStatistics stats: StreamStatistics)
    func streamManager(_ manager: StreamManager, didFailWith error: Error)
}

final class StreamManager: ObservableObject {
    weak var delegate: StreamManagerDelegate?

    @Published var isConnected = false
    @Published var statistics = StreamStatistics()

    private var connection: NWConnection?
    private let encoder = StreamEncoder()
    private let queue = DispatchQueue(label: "com.creatorstudio.stream")
    private var startTime: Date?
    private var timer: Timer?

    let host: NWEndpoint.Host
    let port: NWEndpoint.Port

    init(host: String = "localhost", port: UInt16 = 8080) {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: port) ?? 8080
    }

    func connect() {
        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.connectionTimeout = 5

        let params = NWParameters(tls: nil, tcp: tcpOptions)
        connection = NWConnection(host: host, port: port, using: params)
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.isConnected = true
                    self?.startTime = Date()
                    self?.startStatisticsTimer()
                    self?.delegate?.streamManagerDidConnect(self!)
                case .failed(let error):
                    self?.isConnected = false
                    self?.statistics.isStreaming = false
                    self?.delegate?.streamManager(self!, didFailWith: error)
                case .cancelled:
                    self?.isConnected = false
                    self?.statistics.isStreaming = false
                    self?.delegate?.streamManagerDidDisconnect(self!, error: nil)
                default:
                    break
                }
            }
        }
        connection?.start(queue: queue)
    }

    func disconnect() {
        connection?.cancel()
        timer?.invalidate()
        isConnected = false
        statistics.isStreaming = false
    }

    func sendVideoData(_ sampleBuffer: CMSampleBuffer) {
        guard isConnected, let data = encoder.encodeVideoSampleBuffer(sampleBuffer) else { return }

        statistics.totalFrames += 1
        statistics.bitrate += Double(data.count) * 8

        connection?.send(content: data, completion: .contentProcessed { [weak self] error in
            if error != nil {
                DispatchQueue.main.async {
                    self?.statistics.droppedFrames += 1
                }
            }
        })
    }

    func sendAudioData(_ buffer: AVAudioPCMBuffer) {
        guard isConnected, let data = encoder.encodeAudioBuffer(buffer) else { return }

        connection?.send(content: data, completion: .contentProcessed { _ in })
    }

    private func startStatisticsTimer() {
        statistics.isStreaming = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self, let start = self.startTime else { return }
            self.statistics.uptime = Date().timeIntervalSince(start)
            self.delegate?.streamManager(self, didUpdateStatistics: self.statistics)
        }
    }
}
