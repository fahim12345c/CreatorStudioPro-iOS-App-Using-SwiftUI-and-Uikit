import Combine
import Foundation

final class AppStateManager: ObservableObject {
    static let shared = AppStateManager()

    @Published var isActive: Bool = false
    @Published var isInBackground: Bool = false
    @Published var permissionsGranted: Bool = false
    @Published var currentRecordingTime: TimeInterval = 0

    private init() {}

    func appDidBecomeActive() {
        isActive = true
        isInBackground = false
    }

    func appDidEnterBackground() {
        isActive = false
        isInBackground = true
    }

    func setPermissionsGranted(_ granted: Bool) {
        permissionsGranted = granted
    }
}
