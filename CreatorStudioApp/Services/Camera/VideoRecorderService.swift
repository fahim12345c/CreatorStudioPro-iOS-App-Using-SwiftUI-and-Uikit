import Combine
import AVFoundation
import UIKit

protocol VideoRecorderServiceDelegate: AnyObject {
    func videoRecorderServiceDidStartRecording(_ service: VideoRecorderService)
    func videoRecorderServiceDidPauseRecording(_ service: VideoRecorderService)
    func videoRecorderServiceDidResumeRecording(_ service: VideoRecorderService)
    func videoRecorderServiceDidFinishRecording(_ service: VideoRecorderService, at tempURL: URL)
    func videoRecorderService(_ service: VideoRecorderService, didFailWith error: Error)
    func videoRecorderServiceWasInterrupted(_ service: VideoRecorderService)
}

final class VideoRecorderService: NSObject {
    weak var delegate: VideoRecorderServiceDelegate?

    @Published var isRecording = false
    @Published var isPaused = false
    @Published var recordingDuration: TimeInterval = 0

    private let movieOutput = AVCaptureMovieFileOutput()
    private let recordingQueue = DispatchQueue(label: "com.creatorstudio.videorecorder")
    private var recordingTimer: Timer?
    private var recordingStartDate: Date?
    private var pausedDuration: TimeInterval = 0
    private var pauseStartDate: Date?
    private var currentTempURL: URL?
    private let storageManager = StorageManager.shared

    var maxRecordingDuration: TimeInterval = AppConstants.Video.maxDuration

    var isReady: Bool {
        movieOutput.connection(with: .video) != nil
    }

    override init() {
        super.init()
        registerInterruptionHandler()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func configure(with session: AVCaptureSession) {
        guard session.canAddOutput(movieOutput) else { return }
        session.addOutput(movieOutput)
        if let connection = movieOutput.connection(with: .video) {
            connection.preferredVideoStabilizationMode = .auto
        }
    }

    func startRecording() {
        guard !isRecording else { return }
        guard movieOutput.connection(with: .video) != nil else {
            delegate?.videoRecorderService(self, didFailWith: CameraError.noVideoConnection)
            return
        }

        pausedDuration = 0
        isPaused = false

        let fileName = FileNames.uniqueFilename(extension: "mov")
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        currentTempURL = tempURL

        recordingQueue.async { [weak self] in
            guard let self else { return }
            self.movieOutput.startRecording(to: tempURL, recordingDelegate: self)
        }

        recordingStartDate = Date()
        startTimer()
    }

    func pauseRecording() {
        guard isRecording, !isPaused else { return }
        isPaused = true
        pauseStartDate = Date()
        recordingTimer?.invalidate()
        recordingTimer = nil
        delegate?.videoRecorderServiceDidPauseRecording(self)
    }

    func resumeRecording() {
        guard isRecording, isPaused else { return }
        isPaused = false
        if let pauseStart = pauseStartDate {
            pausedDuration += Date().timeIntervalSince(pauseStart)
        }
        pauseStartDate = nil
        startTimer()
        delegate?.videoRecorderServiceDidResumeRecording(self)
    }

    func stopRecording() {
        guard isRecording else { return }
        recordingQueue.async { [weak self] in
            self?.movieOutput.stopRecording()
        }
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    private func startTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, let startDate = self.recordingStartDate else { return }
            let elapsed = Date().timeIntervalSince(startDate) - self.pausedDuration
            self.recordingDuration = elapsed
            if elapsed >= self.maxRecordingDuration { self.stopRecording() }
        }
    }

    private func registerInterruptionHandler() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleInterruption),
            name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc private func handleInterruption() {
        guard isRecording else { return }
        stopRecording()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.videoRecorderServiceWasInterrupted(self)
        }
    }
}

extension VideoRecorderService: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.isRecording = true
            self.delegate?.videoRecorderServiceDidStartRecording(self)
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.isRecording = false
            self.isPaused = false
            self.recordingDuration = 0
            self.recordingTimer?.invalidate()
            self.recordingTimer = nil

            if let error {
                self.delegate?.videoRecorderService(self, didFailWith: error)
                return
            }

            self.delegate?.videoRecorderServiceDidFinishRecording(self, at: outputFileURL)
        }
    }
}
