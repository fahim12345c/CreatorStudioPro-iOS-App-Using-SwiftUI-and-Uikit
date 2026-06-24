import Vision
import AVFoundation
import Combine

protocol ScannerServiceDelegate: AnyObject {
    func scannerService(_ service: ScannerService, didDetect code: ScannerService.ScannedCode)
}

final class ScannerService: NSObject, ObservableObject {
    struct ScannedCode: Identifiable {
        let id = UUID()
        let value: String
        let type: String
        let timestamp: Date
    }

    weak var delegate: ScannerServiceDelegate?

    @Published var isScanning = false
    @Published var lastScannedCode: ScannedCode?

    private let videoOutput = AVCaptureVideoDataOutput()
    private let processingQueue = DispatchQueue(label: "com.creatorstudio.scanner.processing", qos: .userInitiated)
    private weak var session: AVCaptureSession?

    override init() {
        super.init()
        videoOutput.setSampleBufferDelegate(self, queue: processingQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
    }

    func configure(with session: AVCaptureSession) {
        self.session = session
        guard session.canAddOutput(videoOutput) else { return }
        session.addOutput(videoOutput)
    }

    func startScanning() {
        isScanning = true
    }

    func stopScanning() {
        isScanning = false
    }

    private func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard isScanning, let pixelBuffer = sampleBuffer.imageBuffer else { return }

        let request = VNDetectBarcodesRequest { [weak self] request, error in
            guard error == nil,
                  let results = request.results as? [VNBarcodeObservation],
                  let first = results.first else { return }

            guard let value = first.payloadStringValue, !value.isEmpty, let self else { return }

            DispatchQueue.main.async {
                guard self.lastScannedCode == nil || Date().timeIntervalSince(self.lastScannedCode!.timestamp) > 2.0 else { return }
                let code = ScannedCode(value: value, type: first.symbology.rawValue, timestamp: Date())
                self.lastScannedCode = code
                self.delegate?.scannerService(self, didDetect: code)
            }
        }

        let symbologies: [VNBarcodeSymbology] = [.qr, .ean13, .ean8, .code128, .code39, .upce, .codabar]
        request.symbologies = symbologies

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}

extension ScannerService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        processSampleBuffer(sampleBuffer)
    }
}
