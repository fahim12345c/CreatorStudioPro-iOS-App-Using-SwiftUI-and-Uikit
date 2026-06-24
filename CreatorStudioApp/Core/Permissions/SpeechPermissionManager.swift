import Foundation
import Speech

final class SpeechPermissionManager {
    static let shared = SpeechPermissionManager()

    private init() {}

    var status: SFSpeechRecognizerAuthorizationStatus {
        SFSpeechRecognizer.authorizationStatus()
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

    var isNotDetermined: Bool {
        status == .notDetermined
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}
