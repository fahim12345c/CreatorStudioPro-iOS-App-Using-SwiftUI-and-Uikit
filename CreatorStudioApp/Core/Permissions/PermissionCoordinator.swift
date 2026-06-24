import Foundation
import AVFoundation
import Speech

enum PermissionStatus {
    case notDetermined
    case authorized
    case denied
    case restricted
}

struct PermissionState {
    let camera: PermissionStatus
    let microphone: PermissionStatus
    let speech: PermissionStatus

    static let `default` = PermissionState(
        camera: .notDetermined,
        microphone: .notDetermined,
        speech: .notDetermined
    )
}

final class PermissionCoordinator {
    static let shared = PermissionCoordinator()

    private let cameraManager = CameraPermissionManager.shared
    private let microphoneManager = MicrophonePermissionManager.shared
    private let speechManager = SpeechPermissionManager.shared

    private init() {}

    var currentState: PermissionState {
        PermissionState(
            camera: mapStatus(cameraManager.status),
            microphone: mapMicStatus(microphoneManager.status),
            speech: mapSpeechStatus(speechManager.status)
        )
    }

    var allRequiredGranted: Bool {
        cameraManager.isAuthorized && microphoneManager.isAuthorized
    }

    var allGranted: Bool {
        cameraManager.isAuthorized && microphoneManager.isAuthorized && speechManager.isAuthorized
    }

    func requestAllPermissions() async -> Bool {
        let cameraGranted = await cameraManager.requestPermission()
        let micGranted = await microphoneManager.requestPermission()
        return cameraGranted && micGranted
    }

    func requestCameraAndMicrophone() async -> Bool {
        let cameraGranted = await cameraManager.requestPermission()
        let micGranted = await microphoneManager.requestPermission()
        return cameraGranted && micGranted
    }

    func requestSpeechPermission() async -> Bool {
        await speechManager.requestPermission()
    }

    private func mapStatus(_ status: AVAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .authorized: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }

    private func mapMicStatus(_ status: AVAudioSession.RecordPermission) -> PermissionStatus {
        switch status {
        case .undetermined: return .notDetermined
        case .granted: return .authorized
        case .denied: return .denied
        @unknown default: return .denied
        }
    }

    private func mapSpeechStatus(_ status: SFSpeechRecognizerAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .authorized: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }
}
