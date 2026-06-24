import SwiftUI

struct FaceBoundingBox: View {
    let face: FaceModel
    let previewSize: CGSize
    let videoSize: CGSize

    var body: some View {
        let rect = convertRect(face.boundingBox)
        return ZStack {
            Rectangle()
                .strokeBorder(genderColor, lineWidth: 2)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)

            VStack(spacing: 2) {
                Text(face.gender.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(genderColor.opacity(0.85))
                    .cornerRadius(4)
            }
            .position(x: rect.midX, y: rect.minY - 12)
        }
    }

    private var genderColor: Color {
        switch face.gender {
        case .male: return .blue
        case .female: return .pink
        case .unknown: return .yellow
        }
    }

    private func convertRect(_ boundingBox: CGRect) -> CGRect {
        guard videoSize.width > 0, videoSize.height > 0,
              previewSize.width > 0, previewSize.height > 0 else {
            let x = boundingBox.origin.x * previewSize.width
            let y = (1 - boundingBox.origin.y - boundingBox.height) * previewSize.height
            let w = boundingBox.width * previewSize.width
            let h = boundingBox.height * previewSize.height
            return CGRect(x: x, y: y, width: w, height: h)
        }

        let videoAspect = videoSize.width / videoSize.height
        let viewAspect = previewSize.width / previewSize.height

        let visibleX: CGFloat
        let visibleWidth: CGFloat
        let visibleY: CGFloat
        let visibleHeight: CGFloat

        if videoAspect > viewAspect {
            let ratio = viewAspect / videoAspect
            visibleX = (1 - ratio) / 2
            visibleWidth = ratio
            visibleY = 0
            visibleHeight = 1
        } else {
            let ratio = videoAspect / viewAspect
            visibleX = 0
            visibleWidth = 1
            visibleY = (1 - ratio) / 2
            visibleHeight = ratio
        }

        let visionY = 1 - boundingBox.origin.y - boundingBox.height

        let viewX = (boundingBox.origin.x - visibleX) / visibleWidth * previewSize.width
        let viewY = (visionY - visibleY) / visibleHeight * previewSize.height
        let viewW = boundingBox.width / visibleWidth * previewSize.width
        let viewH = boundingBox.height / visibleHeight * previewSize.height

        return CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
    }
}
