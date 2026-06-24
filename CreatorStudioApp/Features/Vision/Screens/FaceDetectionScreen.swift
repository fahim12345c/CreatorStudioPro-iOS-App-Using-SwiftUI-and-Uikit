import SwiftUI

struct FaceDetectionScreen: View {
    @StateObject private var viewModel = FaceDetectionViewModel()

    var body: some View {
        ZStack {
            if viewModel.cameraUnavailable {
                VStack(spacing: 16) {
                    Image(systemName: "camera.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.appSecondaryText)
                    Text("Camera Unavailable")
                        .font(.headline)
                    Text("Camera hardware is not available on this device.")
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                CameraPreview(cameraService: viewModel.cameraService)
                    .ignoresSafeArea()

                FaceOverlayView(faces: viewModel.detectedFaces, previewSize: viewModel.previewSize, videoSize: viewModel.videoSize)

                VStack {
                    HStack {
                        Button(action: viewModel.switchCamera) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Faces: \(viewModel.faceCount)")
                                .font(.headline)
                                .foregroundColor(.white)

                            let males = viewModel.detectedFaces.filter { $0.gender == .male }.count
                            let females = viewModel.detectedFaces.filter { $0.gender == .female }.count
                            if males > 0 || females > 0 {
                                HStack(spacing: 6) {
                                    if males > 0 {
                                        Label("\(males)", systemImage: "figure.stand")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    if females > 0 {
                                        Label("\(females)", systemImage: "figure.stand.dress")
                                            .font(.caption)
                                            .foregroundColor(.pink)
                                    }
                                }
                            }
                        }
                        .padding(8)
                        .background(.black.opacity(0.6))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)

                    Spacer()
                }
            }
        }
        .navigationTitle("Face Detection")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }
}
