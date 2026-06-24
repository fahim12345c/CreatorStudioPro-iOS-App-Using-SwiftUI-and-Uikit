import SwiftUI
import Combine
import AVFoundation

@MainActor
final class CameraViewModel: ObservableObject {
    let cameraService = CameraService()
    let photoCaptureService = PhotoCaptureService()
    let videoRecorderService = VideoRecorderService()

    @Published var capturedImage: UIImage?
    @Published var showGallery = false
    @Published var showSettings = false
    @Published var permissionDenied = false
    @Published var sessionConfigured = false
    @Published var currentMode: CameraMode = .photo
    @Published var cameraUnavailable = false
    @Published var isPaused = false
    @Published var showSaveAlert = false
    @Published var pendingVideoURL: URL?
    @Published var isVideoRecording = false
    @Published var videoRecordingDuration: TimeInterval = 0

    enum CameraMode: String, CaseIterable {
        case photo = "Photo"
        case video = "Video"
    }

    private var cancellables = Set<AnyCancellable>()

    init() {
        cameraService.delegate = self
        photoCaptureService.delegate = self
        videoRecorderService.delegate = self

        videoRecorderService.$isRecording
            .assign(to: &$isVideoRecording)
        videoRecorderService.$recordingDuration
            .assign(to: &$videoRecordingDuration)
    }

    func startCamera() {
        guard CameraService.isAvailable else { cameraUnavailable = true; return }
        Task {
            let granted = await PermissionCoordinator.shared.requestCameraAndMicrophone()
            if granted {
                let configured = await cameraService.configureSession()
                if configured {
                    photoCaptureService.configure(with: cameraService.session)
                    videoRecorderService.configure(with: cameraService.session)
                    await cameraService.startSession()
                }
                permissionDenied = false
            } else {
                permissionDenied = true
            }
        }
    }

    func stopCamera() {
        cameraService.stopSession()
    }

    func capturePhoto() {
        guard currentMode == .photo, cameraService.isConfigured else { return }
        photoCaptureService.capturePhoto()
    }

    func toggleRecording() {
        guard currentMode == .video, cameraService.isConfigured, videoRecorderService.isReady else { return }
        if isVideoRecording {
            videoRecorderService.stopRecording()
        } else {
            videoRecorderService.startRecording()
        }
    }

    func pauseRecording() {
        videoRecorderService.pauseRecording()
        isPaused = true
    }

    func resumeRecording() {
        videoRecorderService.resumeRecording()
        isPaused = false
    }

    func saveVideo() {
        guard let url = pendingVideoURL else { return }
        let savedURL = StorageManager.shared.saveVideo(from: url)
        if savedURL != nil {
            Logger.info("Video saved", category: .camera)
        }
        pendingVideoURL = nil
        showSaveAlert = false
    }

    func discardVideo() {
        guard let url = pendingVideoURL else { return }
        try? FileManager.default.removeItem(at: url)
        pendingVideoURL = nil
        showSaveAlert = false
    }

    func switchCamera() { cameraService.switchCamera() }
    func toggleTorch() { cameraService.toggleTorch() }
    func setZoom(_ factor: CGFloat) { cameraService.setZoom(factor) }
}

extension CameraViewModel: CameraServiceDelegate {
    func cameraService(_ service: CameraService, didOutput sampleBuffer: CMSampleBuffer) {}
    func cameraServiceDidStartSession(_ service: CameraService) { sessionConfigured = true }
    func cameraServiceDidStopSession(_ service: CameraService) {}
    func cameraService(_ service: CameraService, didFailWith error: Error) {
        Logger.error("Camera service failed", category: .camera, error: error)
    }
}

extension CameraViewModel: PhotoCaptureServiceDelegate {
    func photoCaptureService(_ service: PhotoCaptureService, didCapture photo: UIImage) { capturedImage = photo }
    func photoCaptureService(_ service: PhotoCaptureService, didSaveTo url: URL) {}
    func photoCaptureService(_ service: PhotoCaptureService, didFailWith error: Error) {
        Logger.error("Photo capture failed", category: .camera, error: error)
    }
}

extension CameraViewModel: VideoRecorderServiceDelegate {
    func videoRecorderServiceDidStartRecording(_ service: VideoRecorderService) { isPaused = false }
    func videoRecorderServiceDidPauseRecording(_ service: VideoRecorderService) { isPaused = true }
    func videoRecorderServiceDidResumeRecording(_ service: VideoRecorderService) { isPaused = false }
    func videoRecorderServiceDidFinishRecording(_ service: VideoRecorderService, at tempURL: URL) {
        isPaused = false
        pendingVideoURL = tempURL
        showSaveAlert = true
    }
    func videoRecorderService(_ service: VideoRecorderService, didFailWith error: Error) {
        isPaused = false
        Logger.error("Video recording failed", category: .camera, error: error)
    }
    func videoRecorderServiceWasInterrupted(_ service: VideoRecorderService) { isPaused = false }
}
