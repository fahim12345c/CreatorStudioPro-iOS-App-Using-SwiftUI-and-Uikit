import UIKit
import AVFoundation

final class MultiCamViewController: UIViewController {
    private let multiCamService: MultiCamService
    private var frontPreviewLayer: AVCaptureVideoPreviewLayer?
    private var backPreviewLayer: AVCaptureVideoPreviewLayer?

    init(multiCamService: MultiCamService = .shared) {
        self.multiCamService = multiCamService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreviewLayers()
    }

    private func setupPreviewLayers() {
        let frontLayer = AVCaptureVideoPreviewLayer(session: multiCamService.frontSession)
        frontLayer.videoGravity = .resizeAspectFill

        let backLayer = AVCaptureVideoPreviewLayer(session: multiCamService.backSession)
        backLayer.videoGravity = .resizeAspectFill

        view.layer.addSublayer(backLayer)
        view.layer.addSublayer(frontLayer)

        frontPreviewLayer = frontLayer
        backPreviewLayer = backLayer
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let midX = view.bounds.midX
        let midY = view.bounds.midY

        backPreviewLayer?.frame = view.bounds

        let pipSize = CGSize(width: view.bounds.width * 0.3, height: view.bounds.height * 0.25)
        frontPreviewLayer?.frame = CGRect(
            x: view.bounds.width - pipSize.width - 16,
            y: view.bounds.height - pipSize.height - 16 - view.safeAreaInsets.bottom,
            width: pipSize.width,
            height: pipSize.height
        )
        frontPreviewLayer?.cornerRadius = 8
        frontPreviewLayer?.masksToBounds = true
    }
}
