import AVFoundation
import UIKit

protocol InterviewSessionManagerDelegate: AnyObject {
    func interviewSessionManager(_ manager: InterviewSessionManager, didUpdateTranscript text: String)
    func interviewSessionManager(_ manager: InterviewSessionManager, didDetectFaces faces: [FaceModel])
    func interviewSessionManager(_ manager: InterviewSessionManager, didUpdateAudioLevel level: Float)
    func interviewSessionManager(_ manager: InterviewSessionManager, didUpdateElapsedTime time: TimeInterval)
    func interviewSessionManagerDidStartRecording(_ manager: InterviewSessionManager)
    func interviewSessionManagerDidStopRecording(_ manager: InterviewSessionManager)
    func interviewSessionManager(_ manager: InterviewSessionManager, didFailWith error: Error)
}

final class InterviewSessionManager {
    weak var delegate: InterviewSessionManagerDelegate?

    let cameraService = CameraService()
    let speechService = SpeechRecognitionService()
    let faceDetectionService = FaceDetectionService()
    let audioEngineService = AudioEngineService()
    let recorderService = AudioRecorderService()

    private var sessionTimer: Timer?
    private var startTime: Date?
    private var isRunning = false

    init() {
        cameraService.delegate = self
        speechService.delegate = self
        faceDetectionService.delegate = self
        audioEngineService.delegate = self
        recorderService.delegate = self
    }

    func startSession() {
        guard !isRunning else { return }
        Task {
            let configured = await cameraService.configureSession()
            if configured {
                await cameraService.startSession()
            }
        }
        speechService.startRecognition()
        try? audioEngineService.startEngine()
        startTime = Date()

        sessionTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self, let start = self.startTime else { return }
            self.delegate?.interviewSessionManager(self, didUpdateElapsedTime: Date().timeIntervalSince(start))
        }
        isRunning = true
    }

    func stopSession() {
        cameraService.stopSession()
        recorderService.stopRecording()
        speechService.stopRecognition()
        audioEngineService.stopEngine()
        sessionTimer?.invalidate()
        sessionTimer = nil
        isRunning = false
    }

    func startRecording() {
        recorderService.startRecording()
    }

    func stopRecording() {
        recorderService.stopRecording()
    }
}

extension InterviewSessionManager: CameraServiceDelegate {
    func cameraService(_ service: CameraService, didOutput sampleBuffer: CMSampleBuffer) {
        faceDetectionService.detectFaces(in: sampleBuffer)
    }
    func cameraServiceDidStartSession(_ service: CameraService) {}
    func cameraServiceDidStopSession(_ service: CameraService) {}
    func cameraService(_ service: CameraService, didFailWith error: Error) {}
}

extension InterviewSessionManager: SpeechRecognitionServiceDelegate {
    func speechRecognitionService(_ service: SpeechRecognitionService, didTranscribe text: String, isFinal: Bool) {
        delegate?.interviewSessionManager(self, didUpdateTranscript: text)
    }
    func speechRecognitionService(_ service: SpeechRecognitionService, didUpdateAvailability available: Bool) {}
    func speechRecognitionService(_ service: SpeechRecognitionService, didFailWith error: Error) {}
}

extension InterviewSessionManager: FaceDetectionServiceDelegate {
    func faceDetectionService(_ service: FaceDetectionService, didDetect faces: [FaceModel]) {
        delegate?.interviewSessionManager(self, didDetectFaces: faces)
    }
    func faceDetectionService(_ service: FaceDetectionService, didFailWith error: Error) {}
}

extension InterviewSessionManager: AudioEngineServiceDelegate {
    func audioEngineService(_ service: AudioEngineService, didCaptureBuffer buffer: AVAudioPCMBuffer, at time: AVAudioTime) {}
    func audioEngineService(_ service: AudioEngineService, didUpdateAveragePower power: Float) {
        delegate?.interviewSessionManager(self, didUpdateAudioLevel: power)
    }
    func audioEngineService(_ service: AudioEngineService, didFailWith error: Error) {
        delegate?.interviewSessionManager(self, didFailWith: error)
    }
}

extension InterviewSessionManager: AudioRecorderServiceDelegate {
    func audioRecorderServiceDidStartRecording(_ service: AudioRecorderService) {
        delegate?.interviewSessionManagerDidStartRecording(self)
    }
    func audioRecorderServiceDidFinishRecording(_ service: AudioRecorderService, at url: URL) {
        delegate?.interviewSessionManagerDidStopRecording(self)
    }
    func audioRecorderService(_ service: AudioRecorderService, didUpdateAveragePower power: Float) {}
    func audioRecorderService(_ service: AudioRecorderService, didFailWith error: Error) {
        delegate?.interviewSessionManager(self, didFailWith: error)
    }
    func audioRecorderServiceDidPauseRecording(_ service: AudioRecorderService) {}
    func audioRecorderServiceDidResumeRecording(_ service: AudioRecorderService) {}
}
