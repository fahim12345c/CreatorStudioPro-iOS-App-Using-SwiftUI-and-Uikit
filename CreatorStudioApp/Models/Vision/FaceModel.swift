import Foundation
import CoreGraphics

enum FaceGender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case unknown = "Unknown"
}

struct FaceModel: Identifiable {
    let id: UUID
    let boundingBox: CGRect
    let confidence: Float
    let landmarks: FaceLandmarks?
    let rollAngle: NSNumber?
    let pitchAngle: NSNumber?
    let yawAngle: NSNumber?
    let gender: FaceGender

    struct FaceLandmarks {
        let leftEye: CGRect?
        let rightEye: CGRect?
        let nose: CGRect?
        let mouth: CGRect?
        let leftEyebrow: CGRect?
        let rightEyebrow: CGRect?

        let leftEyePoints: [CGPoint]?
        let rightEyePoints: [CGPoint]?
        let nosePoints: [CGPoint]?
        let mouthPoints: [CGPoint]?
        let leftEyebrowPoints: [CGPoint]?
        let rightEyebrowPoints: [CGPoint]?
        let faceContourPoints: [CGPoint]?
    }

    init(id: UUID = UUID(), boundingBox: CGRect, confidence: Float, landmarks: FaceLandmarks? = nil,
         rollAngle: NSNumber? = nil, pitchAngle: NSNumber? = nil, yawAngle: NSNumber? = nil,
         gender: FaceGender = .unknown) {
        self.id = id
        self.boundingBox = boundingBox
        self.confidence = confidence
        self.landmarks = landmarks
        self.rollAngle = rollAngle
        self.pitchAngle = pitchAngle
        self.yawAngle = yawAngle
        self.gender = gender
    }
}
