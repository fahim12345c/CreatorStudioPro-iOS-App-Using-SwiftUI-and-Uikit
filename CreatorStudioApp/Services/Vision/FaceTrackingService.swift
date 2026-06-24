import Combine
import Vision
import AVFoundation

protocol FaceTrackingServiceDelegate: AnyObject {
    func faceTrackingService(_ service: FaceTrackingService, didTrack faces: [FaceModel])
    func faceTrackingServiceDidLoseTracking(_ service: FaceTrackingService)
}

final class FaceTrackingService {
    weak var delegate: FaceTrackingServiceDelegate?

    @Published var trackedFaces: [FaceModel] = []
    @Published var faceCount: Int = 0
    @Published var isTracking = false

    private let faceDetectionService: FaceDetectionService
    private var trackingRequests: [VNTrackObjectRequest] = []
    private let sequenceHandler = VNSequenceRequestHandler()
    private let trackingQueue = DispatchQueue(label: "com.creatorstudio.facetracking")
    private var lastDetectedGenders: [FaceGender] = []

    init(faceDetectionService: FaceDetectionService) {
        self.faceDetectionService = faceDetectionService
        self.faceDetectionService.delegate = self
    }

    func startTracking() {
        isTracking = true
    }

    func stopTracking() {
        isTracking = false
        trackingRequests.removeAll()
        trackedFaces = []
        faceCount = 0
        lastDetectedGenders = []
    }

    func processFrame(_ sampleBuffer: CMSampleBuffer) {
        guard isTracking else { return }

        if trackingRequests.isEmpty {
            faceDetectionService.detectFaces(in: sampleBuffer)
            return
        }

        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }

        trackingQueue.async { [weak self] in
            guard let self else { return }

            do {
                try self.sequenceHandler.perform(self.trackingRequests, on: pixelBuffer)

                var tracked: [FaceModel] = []
                var updatedRequests: [VNTrackObjectRequest] = []

                for (request, gender) in zip(self.trackingRequests, self.lastDetectedGenders) {
                    guard let result = request.results?.first as? VNFaceObservation else { continue }

                    if request.isLastFrame {
                        continue
                    }

                    let face = FaceModel(
                        boundingBox: result.boundingBox,
                        confidence: result.confidence,
                        gender: gender
                    )
                    tracked.append(face)

                    let newRequest = VNTrackObjectRequest(detectedObjectObservation: result)
                    newRequest.trackingLevel = .accurate
                    updatedRequests.append(newRequest)
                }

                DispatchQueue.main.async {
                    self.trackedFaces = tracked
                    self.faceCount = tracked.count
                    self.trackingRequests = updatedRequests

                    if tracked.isEmpty {
                        self.delegate?.faceTrackingServiceDidLoseTracking(self)
                    } else {
                        self.delegate?.faceTrackingService(self, didTrack: tracked)
                    }
                }
            } catch {
                Logger.error("Face tracking failed", category: .vision, error: error)
            }
        }
    }
}

extension FaceTrackingService: FaceDetectionServiceDelegate {
    func faceDetectionService(_ service: FaceDetectionService, didDetect faces: [FaceModel]) {
        lastDetectedGenders = faces.map { $0.gender }
        trackingQueue.async { [weak self] in
            guard let self else { return }
            self.trackingRequests = faces.map { face in
                let observation = VNDetectedObjectObservation(
                    boundingBox: face.boundingBox
                )
                let request = VNTrackObjectRequest(detectedObjectObservation: observation)
                request.trackingLevel = .accurate
                return request
            }
        }
    }

    func faceDetectionService(_ service: FaceDetectionService, didFailWith error: Error) {
        Logger.error("Face detection failed for tracking", category: .vision, error: error)
    }
}
