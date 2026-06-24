import Vision
import CoreGraphics

final class FaceGenderClassifier {

    private var history: [[CGPoint]: [FaceGender]] = [:]
    private let historySize = 8

    func classifyGender(boundingBox: CGRect, landmarks: FaceModel.FaceLandmarks?) -> FaceGender {
        guard let landmarks else { return .unknown }

        var maleVotes = 0
        var femaleVotes = 0

        if let contour = landmarks.faceContourPoints, contour.count >= 8 {
            let jawWidth = computeWidth(at: 0.9, in: contour)
            let cheekWidth = computeWidth(at: 0.5, in: contour)
            let foreheadWidth = computeWidth(at: 0.1, in: contour)

            if jawWidth > 0 {
                let jawCheekRatio = jawWidth / cheekWidth
                if jawCheekRatio > 0.85 { maleVotes += 2 } else { femaleVotes += 2 }

                let jawForeheadRatio = jawWidth / foreheadWidth
                if jawForeheadRatio > 0.90 { maleVotes += 1 } else { femaleVotes += 1 }
            }
        }

        if let leftBrow = landmarks.leftEyebrowPoints, let rightBrow = landmarks.rightEyebrowPoints,
           leftBrow.count >= 3, rightBrow.count >= 3 {
            let browLength = computeCurveLength(leftBrow) + computeCurveLength(rightBrow)
            let browArch = computeArchHeight(leftBrow) + computeArchHeight(rightBrow)

            if browLength > 0.15 { maleVotes += 1 } else { femaleVotes += 1 }
            if browArch > 0.015 { femaleVotes += 1 } else { maleVotes += 1 }
        }

        if let mouth = landmarks.mouthPoints, mouth.count >= 8 {
            let lipFullness = computeLipFullness(mouth)
            if lipFullness > 0.025 { femaleVotes += 2 } else { maleVotes += 1 }
        }

        if let nose = landmarks.nosePoints, nose.count >= 5 {
            let noseWidth = computeWidth(of: nose)
            let noseBridgeWidth = computeNoseBridgeWidth(nose)

            if noseWidth > 0.22 { maleVotes += 1 } else { femaleVotes += 1 }
            if noseBridgeWidth > 0.12 { maleVotes += 1 } else { femaleVotes += 1 }
        }

        if let leftEye = landmarks.leftEyePoints, let rightEye = landmarks.rightEyePoints,
           leftEye.count >= 5, rightEye.count >= 5 {
            let leftEyeSize = computeEyeSize(leftEye)
            let rightEyeSize = computeEyeSize(rightEye)
            let avgEyeSize = (leftEyeSize + rightEyeSize) / 2

            if avgEyeSize > 0.045 { femaleVotes += 1 } else { maleVotes += 1 }
        }

        if let contour = landmarks.faceContourPoints, contour.count >= 6 {
            let chinPoint = contour.last!
            let chinSharpness = abs(chinPoint.x - 0.5)
            if chinSharpness > 0.08 { maleVotes += 1 } else { femaleVotes += 1 }
        }

        let total = maleVotes + femaleVotes
        guard total >= 3 else { return .unknown }

        let raw: FaceGender
        if maleVotes > femaleVotes { raw = .male }
        else if femaleVotes > maleVotes { raw = .female }
        else { raw = .unknown }

        return smoothResult(raw, key: landmarks)
    }

    private func smoothResult(_ current: FaceGender, key: FaceModel.FaceLandmarks) -> FaceGender {
        guard current != .unknown else { return current }

        let hashKey = hashLandmarks(key)
        var buffer = history[hashKey] ?? []
        buffer.append(current)
        if buffer.count > historySize { buffer.removeFirst() }
        history[hashKey] = buffer

        let males = buffer.filter { $0 == .male }.count
        let females = buffer.filter { $0 == .female }.count

        if males > females { return .male }
        if females > males { return .female }
        return current
    }

    private func hashLandmarks(_ landmarks: FaceModel.FaceLandmarks) -> [CGPoint] {
        var points: [CGPoint] = []
        if let p = landmarks.leftEyePoints?.first { points.append(p) }
        if let p = landmarks.rightEyePoints?.first { points.append(p) }
        if let p = landmarks.nosePoints?.first { points.append(p) }
        if let p = landmarks.mouthPoints?.first { points.append(p) }
        return points
    }

    func resetHistory() { history.removeAll() }

    private func computeWidth(at yPosition: CGFloat, in points: [CGPoint]) -> CGFloat {
        let startY = points.first!.y
        let endY = points.last!.y
        let targetY = startY + (endY - startY) * yPosition
        var minX: CGFloat = 1, maxX: CGFloat = 0
        for point in points {
            if abs(point.y - targetY) < 0.05 {
                minX = min(minX, point.x)
                maxX = max(maxX, point.x)
            }
        }
        return maxX - minX
    }

    private func computeWidth(of points: [CGPoint]) -> CGFloat {
        let xs = points.map(\.x)
        return (xs.max() ?? 0) - (xs.min() ?? 0)
    }

    private func computeCurveLength(_ points: [CGPoint]) -> CGFloat {
        guard points.count >= 2 else { return 0 }
        var length: CGFloat = 0
        for i in 1..<points.count {
            let dx = points[i].x - points[i-1].x
            let dy = points[i].y - points[i-1].y
            length += sqrt(dx*dx + dy*dy)
        }
        return length
    }

    private func computeArchHeight(_ points: [CGPoint]) -> CGFloat {
        guard points.count >= 3 else { return 0 }
        let start = points.first!
        let end = points.last!
        let midIndex = points.count / 2
        let mid = points[midIndex]
        let baseY = start.y + (end.y - start.y) * 0.5
        return abs(mid.y - baseY)
    }

    private func computeLipFullness(_ mouthPoints: [CGPoint]) -> CGFloat {
        guard mouthPoints.count >= 8 else { return 0 }
        let upperLip = Array(mouthPoints.prefix(6))
        let lowerLip = Array(mouthPoints.suffix(6))
        let upperCenter = upperLip[upperLip.count / 2]
        let lowerCenter = lowerLip[lowerLip.count / 2]
        return abs(upperCenter.y - lowerCenter.y)
    }

    private func computeNoseBridgeWidth(_ nosePoints: [CGPoint]) -> CGFloat {
        guard nosePoints.count >= 3 else { return 0 }
        let bridgeIndex = nosePoints.count / 2
        let bridge = nosePoints[bridgeIndex]
        var count = 0
        for point in nosePoints {
            if abs(point.y - bridge.y) < 0.04 { count += 1 }
        }
        return CGFloat(count) * 0.01
    }

    private func computeEyeSize(_ eyePoints: [CGPoint]) -> CGFloat {
        let xs = eyePoints.map(\.x)
        let ys = eyePoints.map(\.y)
        let width = (xs.max() ?? 0) - (xs.min() ?? 0)
        let height = (ys.max() ?? 0) - (ys.min() ?? 0)
        return width * height
    }
}
