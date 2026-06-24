import SwiftUI
import Combine
import AVFoundation

@MainActor
final class FaceDetectionViewModel: ObservableObject {
    let cameraService = CameraService()
    let detectionService = FaceDetectionService()

    @Published var detectedFaces: [FaceModel] = []
    @Published var isDetecting = false
    @Published var faceCount = 0
    @Published var cameraUnavailable = false
    @Published var videoSize: CGSize = .zero

    private var cancellables = Set<AnyCancellable>()

    init() {
        cameraService.delegate = self
        detectionService.delegate = self
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
                }
            }
        }
    }

    func stop() {
        cameraService.stopSession()
    }

    func switchCamera() { cameraService.switchCamera() }

    var previewSize: CGSize {
        UIScreen.main.bounds.size
    }
}

extension FaceDetectionViewModel: CameraServiceDelegate {
    func cameraService(_ service: CameraService, didOutput sampleBuffer: CMSampleBuffer) {
        detectionService.detectFaces(in: sampleBuffer)
    }

    func cameraServiceDidStartSession(_ service: CameraService) {}
    func cameraServiceDidStopSession(_ service: CameraService) {}
    func cameraService(_ service: CameraService, didFailWith error: Error) {}
}

extension FaceDetectionViewModel: FaceDetectionServiceDelegate {
    func faceDetectionService(_ service: FaceDetectionService, didDetect faces: [FaceModel]) {
        detectedFaces = faces
        faceCount = faces.count
    }

    func faceDetectionService(_ service: FaceDetectionService, didFailWith error: Error) {}
}
