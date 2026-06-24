import SwiftUI

struct FaceTrackingScreen: View {
    @StateObject private var viewModel = FaceTrackingViewModel()

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
                        VStack(spacing: 4) {
                            Text("Tracking: \(viewModel.faceCount)")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(viewModel.faceCount > 0 ? "Tracking" : "No Face")
                                .font(.caption)
                                .foregroundColor(viewModel.faceCount > 0 ? .green : .yellow)
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
        .navigationTitle("Face Tracking")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }
}
