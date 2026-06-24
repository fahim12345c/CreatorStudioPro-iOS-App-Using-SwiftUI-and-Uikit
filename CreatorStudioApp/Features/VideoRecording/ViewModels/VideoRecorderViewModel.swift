import SwiftUI
import Combine

@MainActor
final class VideoRecorderViewModel: ObservableObject {
    let cameraService = CameraService()
    let videoRecorderService = VideoRecorderService()

    @Published var isRecording = false
    @Published var savedURL: URL?
    @Published var showLibrary = false
    @Published var permissionDenied = false
    @Published var cameraUnavailable = false
    @Published var wasInterrupted = false

    var canRecord: Bool {
        cameraService.isConfigured && videoRecorderService.isReady
    }

    init() {
        videoRecorderService.delegate = self
    }

    func startCamera() {
        guard CameraService.isAvailable else { cameraUnavailable = true; return }
        Task {
            let granted = await PermissionCoordinator.shared.requestCameraAndMicrophone()
            if granted {
                let configured = await cameraService.configureSession()
                if configured {
                    videoRecorderService.configure(with: cameraService.session)
                    await cameraService.startSession()
                }
                permissionDenied = false
            } else {
                permissionDenied = true
            }
        }
    }

    func stopCamera() { cameraService.stopSession() }

    func toggleRecording() {
        guard cameraService.isConfigured, videoRecorderService.isReady else { return }
        if isRecording { videoRecorderService.stopRecording() } else { videoRecorderService.startRecording() }
    }
}

extension VideoRecorderViewModel: VideoRecorderServiceDelegate {
    func videoRecorderServiceDidStartRecording(_ service: VideoRecorderService) { isRecording = true }
    func videoRecorderServiceDidPauseRecording(_ service: VideoRecorderService) {}
    func videoRecorderServiceDidResumeRecording(_ service: VideoRecorderService) {}
    func videoRecorderServiceDidFinishRecording(_ service: VideoRecorderService, at tempURL: URL) {
        isRecording = false
        savedURL = tempURL
    }
    func videoRecorderService(_ service: VideoRecorderService, didFailWith error: Error) {
        isRecording = false
        Logger.error("Video recording failed", category: .camera, error: error)
    }
    func videoRecorderServiceWasInterrupted(_ service: VideoRecorderService) { isRecording = false }
}
