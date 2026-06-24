import SwiftUI
import AVFoundation

struct MultiCamPreview: UIViewControllerRepresentable {
    let multiCamService: MultiCamService

    func makeUIViewController(context: Context) -> MultiCamViewController {
        MultiCamViewController(multiCamService: multiCamService)
    }

    func updateUIViewController(_ uiViewController: MultiCamViewController, context: Context) {}
}
