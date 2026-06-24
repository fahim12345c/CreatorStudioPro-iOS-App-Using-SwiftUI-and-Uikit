import SwiftUI
import Combine

@MainActor
final class MultiCamViewModel: ObservableObject {
    let multiCamService = MultiCamService.shared

    @Published var isRunning = false
    @Published var frontRunning = false
    @Published var backRunning = false
    @Published var permissionDenied = false

    func toggleMultiCam() {
        if isRunning {
            multiCamService.stopMultiCamSession()
            isRunning = false
        } else {
            Task {
                let granted = await PermissionCoordinator.shared.requestCameraAndMicrophone()
                if granted {
                    multiCamService.startMultiCamSession()
                    isRunning = multiCamService.isRunning
                    frontRunning = multiCamService.frontCameraRunning
                    backRunning = multiCamService.backCameraRunning
                    permissionDenied = false
                } else {
                    permissionDenied = true
                }
            }
        }
    }
}
