import Combine
import AVFoundation
import UIKit
import Vision

protocol FrameCaptureServiceDelegate: AnyObject {
    func frameCaptureService(_ service: FrameCaptureService, didProcessFrame sampleBuffer: CMSampleBuffer)
    func frameCaptureService(_ service: FrameCaptureService, didUpdateFPS fps: Double)
}

final class FrameCaptureService: NSObject {
    weak var delegate: FrameCaptureServiceDelegate?

    @Published var currentFPS: Double = 0
    @Published var frameCount: Int = 0

    private var lastTimestamp: CMTime = .zero
    private var frameTimestamps: [CMTime] = []
    private let fpsQueue = DispatchQueue(label: "com.creatorstudio.fps")
    private var isProcessing = false

    func processFrame(_ sampleBuffer: CMSampleBuffer) {
        guard !isProcessing else { return }
        isProcessing = true

        defer { isProcessing = false }

        let timestamp = sampleBuffer.presentationTime
        frameTimestamps.append(timestamp)

        fpsQueue.async { [weak self] in
            guard let self else { return }
            self.calculateFPS()
        }

        delegate?.frameCaptureService(self, didProcessFrame: sampleBuffer)

        if let imageBuffer = sampleBuffer.imageBuffer {
            performVisionDetection(on: imageBuffer)
        }
    }

    private func calculateFPS() {
        let now = CMClockGetTime(CMClockGetHostTimeClock())
        let recent = frameTimestamps.filter { CMTimeCompare(CMTimeSubtract(now, $0), CMTimeMake(value: 1, timescale: 1)) < 0 }

        DispatchQueue.main.async {
            self.frameCount = recent.count
            self.currentFPS = Double(recent.count)
            self.delegate?.frameCaptureService(self, didUpdateFPS: self.currentFPS)
        }
    }

    private func performVisionDetection(on imageBuffer: CVImageBuffer) {
        // Subclasses can override this for vision processing
    }
}
