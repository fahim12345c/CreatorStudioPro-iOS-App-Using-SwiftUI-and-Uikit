import Combine
import Vision
import AVFoundation
import CoreImage

protocol FaceDetectionServiceDelegate: AnyObject {
    func faceDetectionService(_ service: FaceDetectionService, didDetect faces: [FaceModel])
    func faceDetectionService(_ service: FaceDetectionService, didFailWith error: Error)
}

final class FaceDetectionService {
    weak var delegate: FaceDetectionServiceDelegate?

    @Published var detectedFaces: [FaceModel] = []
    @Published var isDetecting = false

    let genderClassifier = FaceGenderClassifier()

    private let faceDetectionRequest: VNDetectFaceRectanglesRequest
    private let faceLandmarksRequest: VNDetectFaceLandmarksRequest
    private let detectionQueue = DispatchQueue(label: "com.creatorstudio.facedetection", qos: .userInitiated)
    private var lastDetectionTime: Date = .distantPast
    private let minDetectionInterval: TimeInterval = 0.1

    init() {
        faceDetectionRequest = VNDetectFaceRectanglesRequest()
        faceLandmarksRequest = VNDetectFaceLandmarksRequest()
    }

    func detectFaces(in sampleBuffer: CMSampleBuffer) {
        let now = Date()
        guard now.timeIntervalSince(lastDetectionTime) >= minDetectionInterval else { return }
        lastDetectionTime = now

        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }

        isDetecting = true

        detectionQueue.async { [weak self] in
            guard let self else { return }
            let requests = [self.faceDetectionRequest, self.faceLandmarksRequest]
            let handler = VNSequenceRequestHandler()

            do {
                try handler.perform(requests, on: pixelBuffer, orientation: .up)
            } catch {
                DispatchQueue.main.async {
                    self.isDetecting = false
                    self.delegate?.faceDetectionService(self, didFailWith: error)
                }
                return
            }

            guard let observations = self.faceLandmarksRequest.results as? [VNFaceObservation] else {
                DispatchQueue.main.async {
                    self.isDetecting = false
                    self.detectedFaces = []
                    self.delegate?.faceDetectionService(self, didDetect: [])
                }
                return
            }

            self.processObservations(observations, pixelBuffer: pixelBuffer)
        }
    }

    private func processObservations(_ observations: [VNFaceObservation], pixelBuffer: CVPixelBuffer) {
        var faces: [FaceModel] = []
        for observation in observations {
            let landmarks = extractLandmarks(from: observation)
            let gender = genderClassifier.classifyGender(boundingBox: observation.boundingBox, landmarks: landmarks)
            let face = FaceModel(
                boundingBox: observation.boundingBox,
                confidence: observation.confidence,
                landmarks: landmarks,
                gender: gender
            )
            faces.append(face)
        }

        DispatchQueue.main.async {
            self.detectedFaces = faces
            self.isDetecting = false
            self.delegate?.faceDetectionService(self, didDetect: faces)
        }
    }

    private func extractLandmarks(from observation: VNFaceObservation) -> FaceModel.FaceLandmarks? {
        guard let landmarks = observation.landmarks else { return nil }

        func toPoints(_ region: VNFaceLandmarkRegion2D?) -> [CGPoint]? {
            guard let region, !region.normalizedPoints.isEmpty else { return nil }
            return region.normalizedPoints.map { CGPoint(x: CGFloat($0.x), y: CGFloat($0.y)) }
        }

        return FaceModel.FaceLandmarks(
            leftEye: landmarks.leftEye?.normalizedPointsToBoundingBox(),
            rightEye: landmarks.rightEye?.normalizedPointsToBoundingBox(),
            nose: landmarks.nose?.normalizedPointsToBoundingBox(),
            mouth: landmarks.outerLips?.normalizedPointsToBoundingBox(),
            leftEyebrow: landmarks.leftEyebrow?.normalizedPointsToBoundingBox(),
            rightEyebrow: landmarks.rightEyebrow?.normalizedPointsToBoundingBox(),
            leftEyePoints: toPoints(landmarks.leftEye),
            rightEyePoints: toPoints(landmarks.rightEye),
            nosePoints: toPoints(landmarks.nose),
            mouthPoints: toPoints(landmarks.outerLips),
            leftEyebrowPoints: toPoints(landmarks.leftEyebrow),
            rightEyebrowPoints: toPoints(landmarks.rightEyebrow),
            faceContourPoints: toPoints(landmarks.faceContour)
        )
    }
}

private extension VNFaceLandmarkRegion2D {
    func normalizedPointsToBoundingBox() -> CGRect {
        let points = self.normalizedPoints
        guard !points.isEmpty else { return .zero }

        var minX: CGFloat = 1, minY: CGFloat = 1, maxX: CGFloat = 0, maxY: CGFloat = 0
        for point in points {
            minX = min(minX, CGFloat(point.x))
            minY = min(minY, CGFloat(point.y))
            maxX = max(maxX, CGFloat(point.x))
            maxY = max(maxY, CGFloat(point.y))
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
