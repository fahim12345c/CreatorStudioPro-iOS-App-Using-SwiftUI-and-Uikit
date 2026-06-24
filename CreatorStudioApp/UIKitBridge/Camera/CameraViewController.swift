import UIKit
import AVFoundation

final class CameraViewController: UIViewController {
    private let cameraService: CameraService
    private var previewLayer: AVCaptureVideoPreviewLayer?

    init(cameraService: CameraService) {
        self.cameraService = cameraService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreviewLayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func setupPreviewLayer() {
        let layer = AVCaptureVideoPreviewLayer(session: cameraService.session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        previewLayer = layer
    }
}
