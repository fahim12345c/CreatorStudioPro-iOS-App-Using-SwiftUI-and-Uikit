import SwiftUI
import AVFoundation

struct CameraToolbar: View {
    let onSwitchCamera: () -> Void
    let onToggleTorch: () -> Void
    let onShowGallery: () -> Void
    let onShowSettings: () -> Void
    let torchOn: Bool
    let cameraPosition: AVCaptureDevice.Position

    var body: some View {
        HStack {
            Button(action: onShowGallery) {
                Image(systemName: "photo.on.rectangle")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Spacer()

            Button(action: onToggleTorch) {
                Image(systemName: torchOn ? "bolt.fill" : "bolt.slash")
                    .font(.title2)
                    .foregroundColor(torchOn ? .yellow : .white)
            }

            Button(action: onSwitchCamera) {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
        .padding(.top, 50)
    }
}
