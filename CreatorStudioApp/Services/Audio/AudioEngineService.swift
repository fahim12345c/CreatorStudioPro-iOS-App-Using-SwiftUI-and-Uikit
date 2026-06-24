import Combine
import AVFoundation

protocol AudioEngineServiceDelegate: AnyObject {
    func audioEngineService(_ service: AudioEngineService, didCaptureBuffer buffer: AVAudioPCMBuffer, at time: AVAudioTime)
    func audioEngineService(_ service: AudioEngineService, didUpdateAveragePower power: Float)
    func audioEngineService(_ service: AudioEngineService, didFailWith error: Error)
}

final class AudioEngineService: NSObject {
    weak var delegate: AudioEngineServiceDelegate?

    @Published var isRunning = false
    @Published var averagePower: Float = -160

    let engine = AVAudioEngine()
    private let audioSession = AudioSessionService.shared

    func startEngine() throws {
        try audioSession.configureAudioAnalysis()

        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, time in
            guard let self else { return }

            let channelData = buffer.floatChannelData
            let frameLength = Int(buffer.frameLength)
            var sum: Float = 0

            if let data = channelData?[0] {
                for i in 0..<frameLength {
                    sum += abs(data[i])
                }
                let avg = sum / Float(frameLength)
                let db = 20 * log10(avg + 0.0001)

                DispatchQueue.main.async {
                    self.averagePower = db
                    self.delegate?.audioEngineService(self, didUpdateAveragePower: db)
                }
            }

            self.delegate?.audioEngineService(self, didCaptureBuffer: buffer, at: time)
        }

        engine.prepare()
        try engine.start()
        isRunning = true
    }

    func stopEngine() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        isRunning = false
    }
}
