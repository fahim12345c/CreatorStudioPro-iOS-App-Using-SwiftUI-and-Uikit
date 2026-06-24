import Combine
import AVFoundation

protocol AudioRecorderServiceDelegate: AnyObject {
    func audioRecorderServiceDidStartRecording(_ service: AudioRecorderService)
    func audioRecorderServiceDidPauseRecording(_ service: AudioRecorderService)
    func audioRecorderServiceDidResumeRecording(_ service: AudioRecorderService)
    func audioRecorderServiceDidFinishRecording(_ service: AudioRecorderService, at url: URL)
    func audioRecorderService(_ service: AudioRecorderService, didFailWith error: Error)
    func audioRecorderService(_ service: AudioRecorderService, didUpdateAveragePower power: Float)
}

final class AudioRecorderService: NSObject {
    weak var delegate: AudioRecorderServiceDelegate?

    @Published var isRecording = false
    @Published var isPaused = false
    @Published var currentTime: TimeInterval = 0
    @Published var averagePower: Float = 0

    private var recorder: AVAudioRecorder?
    private var meterTimer: Timer?
    private let audioSession = AudioSessionService.shared
    private let storageManager = StorageManager.shared

    var settings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: AppConstants.Audio.sampleRate,
        AVNumberOfChannelsKey: AppConstants.Audio.numberOfChannels,
        AVEncoderBitRateKey: AppConstants.Audio.bitRate,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    func startRecording() {
        let fileName = FileNames.uniqueFilename(extension: "m4a")
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try audioSession.configureRecording()

            recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.record()

            isRecording = true
            isPaused = false

            meterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.recorder?.updateMeters()
                if let power = self?.recorder?.averagePower(forChannel: 0) {
                    self?.averagePower = power
                    self?.delegate?.audioRecorderService(self!, didUpdateAveragePower: power)
                }
                self?.currentTime = self?.recorder?.currentTime ?? 0
            }

            delegate?.audioRecorderServiceDidStartRecording(self)
        } catch {
            delegate?.audioRecorderService(self, didFailWith: error)
        }
    }

    func pauseRecording() {
        recorder?.pause()
        isPaused = true
        delegate?.audioRecorderServiceDidPauseRecording(self)
    }

    func resumeRecording() {
        recorder?.record()
        isPaused = false
        delegate?.audioRecorderServiceDidResumeRecording(self)
    }

    func stopRecording() {
        meterTimer?.invalidate()
        meterTimer = nil

        let currentURL = recorder?.url
        recorder?.stop()
        recorder = nil

        isRecording = false
        isPaused = false
        currentTime = 0

        if let url = currentURL {
            if let savedURL = storageManager.saveAudio(from: url) {
                delegate?.audioRecorderServiceDidFinishRecording(self, at: savedURL)
            }
        }
    }
}

extension AudioRecorderService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            if let savedURL = storageManager.saveAudio(from: recorder.url) {
                delegate?.audioRecorderServiceDidFinishRecording(self, at: savedURL)
            }
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error {
            delegate?.audioRecorderService(self, didFailWith: error)
        }
    }
}
