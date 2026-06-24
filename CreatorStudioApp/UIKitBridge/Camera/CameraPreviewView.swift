import UIKit
import AVFoundation

final class CameraPreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    var session: AVCaptureSession? {
        get { previewLayer.session }
        set { previewLayer.session = newValue }
    }

    func configure(with session: AVCaptureSession) {
        self.session = session
        previewLayer.videoGravity = .resizeAspectFill
    }
}
