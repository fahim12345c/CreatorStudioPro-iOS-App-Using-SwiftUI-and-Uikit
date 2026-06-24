import SwiftUI

struct FaceOverlayView: View {
    let faces: [FaceModel]
    let previewSize: CGSize
    let videoSize: CGSize

    var body: some View {
        GeometryReader { geo in
            ForEach(faces) { face in
                FaceBoundingBox(face: face, previewSize: geo.size, videoSize: videoSize)
            }
        }
        .allowsHitTesting(false)
    }
}
