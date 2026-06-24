import SwiftUI
import AVFoundation

struct CameraPreview: UIViewControllerRepresentable {
    let cameraService: CameraService

    func makeUIViewController(context: Context) -> CameraViewController {
        CameraViewController(cameraService: cameraService)
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
