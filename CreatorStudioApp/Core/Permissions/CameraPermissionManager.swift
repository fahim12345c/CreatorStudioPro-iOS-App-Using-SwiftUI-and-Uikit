import AVFoundation
import Foundation

final class CameraPermissionManager {
    static let shared = CameraPermissionManager()

    private init() {}

    var status: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    var isAuthorized: Bool {
        status == .authorized
    }

    var isDenied: Bool {
        status == .denied
    }

    var isRestricted: Bool {
        status == .restricted
    }

    func requestPermission() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }
}
