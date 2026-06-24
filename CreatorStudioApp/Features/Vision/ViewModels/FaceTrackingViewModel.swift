import SwiftUI
import Combine
import AVFoundation

@MainActor
final class FaceTrackingViewModel: ObservableObject {
    let cameraService = CameraService()
    let detectionService = FaceDetectionService()
    let trackingService: FaceTrackingService

    @Published var detectedFaces: [FaceModel] = []
    @Published var faceCount = 0
    @Published var isTracking = false
    @Published var cameraUnavailable = false
    @Published var videoSize: CGSize = .zero

    private var cancellables = Set<AnyCancellable>()

    init() {
        trackingService = FaceTrackingService(faceDetectionService: detectionService)
        cameraService.delegate = self
        detectionService.delegate = self
        trackingService.delegate = self
        cameraService.$videoSize.assign(to: &$videoSize)
    }

    func start() {
        guard CameraService.isAvailable else {
            cameraUnavailable = true
            return
        }

        Task {
            let granted = await PermissionCoordinator.shared.requestCameraAndMicrophone()
            if granted {
                let configured = await cameraService.configureSession()
                if configured {
                    await cameraService.startSession()
                    trackingService.startTracking()
                    isTracking = true
                }
            }
        }
    }

    func stop() {
        trackingService.stopTracking()
        cameraService.stopSession()
        isTracking = false
    }

    func switchCamera() { cameraService.switchCamera() }

    var previewSize: CGSize {
        UIScreen.main.bounds.size
    }
}

extension FaceTrackingViewModel: CameraServiceDelegate {
    func cameraService(_ service: CameraService, didOutput sampleBuffer: CMSampleBuffer) {
        trackingService.processFrame(sampleBuffer)
    }

    func cameraServiceDidStartSession(_ service: CameraService) {}
    func cameraServiceDidStopSession(_ service: CameraService) {}
    func cameraService(_ service: CameraService, didFailWith error: Error) {}
}

extension FaceTrackingViewModel: FaceDetectionServiceDelegate {
    func faceDetectionService(_ service: FaceDetectionService, didDetect faces: [FaceModel]) {}

    func faceDetectionService(_ service: FaceDetectionService, didFailWith error: Error) {
        Logger.error("Face detection failed", category: .vision, error: error)
    }
}

extension FaceTrackingViewModel: FaceTrackingServiceDelegate {
    func faceTrackingService(_ service: FaceTrackingService, didTrack faces: [FaceModel]) {
        detectedFaces = faces
        faceCount = faces.count
    }

    func faceTrackingServiceDidLoseTracking(_ service: FaceTrackingService) {
        detectedFaces = []
        faceCount = 0
    }
}
