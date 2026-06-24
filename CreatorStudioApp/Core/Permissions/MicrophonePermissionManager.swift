import AVFoundation
import Foundation

final class MicrophonePermissionManager {
    static let shared = MicrophonePermissionManager()

    private init() {}

    var status: AVAudioSession.RecordPermission {
        AVAudioSession.sharedInstance().recordPermission
    }

    var isAuthorized: Bool {
        status == .granted
    }

    var isDenied: Bool {
        status == .denied
    }

    var isUndetermined: Bool {
        status == .undetermined
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
