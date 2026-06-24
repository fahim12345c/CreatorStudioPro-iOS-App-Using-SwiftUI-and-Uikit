import AVFoundation
import UIKit

protocol PhotoCaptureServiceDelegate: AnyObject {
    func photoCaptureService(_ service: PhotoCaptureService, didCapture photo: UIImage)
    func photoCaptureService(_ service: PhotoCaptureService, didSaveTo url: URL)
    func photoCaptureService(_ service: PhotoCaptureService, didFailWith error: Error)
}

final class PhotoCaptureService: NSObject {
    weak var delegate: PhotoCaptureServiceDelegate?

    private let photoOutput = AVCapturePhotoOutput()
    private let storageManager = StorageManager.shared
    private var photoData: Data?

    func configure(with session: AVCaptureSession) {
        guard session.canAddOutput(photoOutput) else { return }
        session.beginConfiguration()
        session.addOutput(photoOutput)
        session.commitConfiguration()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension PhotoCaptureService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            delegate?.photoCaptureService(self, didFailWith: error)
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }

        photoData = data
        delegate?.photoCaptureService(self, didCapture: image)

        if let url = storageManager.savePhoto(data) {
            delegate?.photoCaptureService(self, didSaveTo: url)
        }
    }
}

enum CameraError: LocalizedError {
    case photoOutputNotConnected
    case sessionNotConfigured
    case permissionDenied
    case noVideoConnection

    var errorDescription: String? {
        switch self {
        case .photoOutputNotConnected: return "Camera is not ready. Please try again."
        case .sessionNotConfigured: return "Camera session could not be configured."
        case .permissionDenied: return "Camera access denied."
        case .noVideoConnection: return "No video connection available for recording."
        }
    }
}
