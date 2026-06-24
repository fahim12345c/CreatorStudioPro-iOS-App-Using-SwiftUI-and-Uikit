import SwiftUI
import Combine

@MainActor
final class InterviewViewModel: ObservableObject {
    let sessionManager = InterviewSessionManager()

    @Published var transcript = ""
    @Published var detectedFaces: [FaceModel] = []
    @Published var audioLevel: Float = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var isSessionActive = false
    @Published var faceCount = 0
    @Published var isRecording = false

    init() {
        sessionManager.delegate = self
    }

    func startSession() {
        Task {
            let granted = await PermissionCoordinator.shared.requestAllPermissions()
            if granted {
                sessionManager.startSession()
                isSessionActive = true
            }
        }
    }

    func stopSession() {
        sessionManager.stopSession()
        isSessionActive = false
        isRecording = false
        elapsedTime = 0
    }

    func toggleRecording() {
        isRecording ? sessionManager.stopRecording() : sessionManager.startRecording()
    }
}

extension InterviewViewModel: InterviewSessionManagerDelegate {
    func interviewSessionManager(_ manager: InterviewSessionManager, didUpdateTranscript text: String) {
        transcript = text
    }

    func interviewSessionManager(_ manager: InterviewSessionManager, didDetectFaces faces: [FaceModel]) {
        detectedFaces = faces
        faceCount = faces.count
    }

    func interviewSessionManager(_ manager: InterviewSessionManager, didUpdateAudioLevel level: Float) {
        audioLevel = level
    }

    func interviewSessionManager(_ manager: InterviewSessionManager, didUpdateElapsedTime time: TimeInterval) {
        elapsedTime = time
    }

    func interviewSessionManagerDidStartRecording(_ manager: InterviewSessionManager) {
        isRecording = true
    }

    func interviewSessionManagerDidStopRecording(_ manager: InterviewSessionManager) {
        isRecording = false
    }

    func interviewSessionManager(_ manager: InterviewSessionManager, didFailWith error: Error) {
        isSessionActive = false
        isRecording = false
    }
}
