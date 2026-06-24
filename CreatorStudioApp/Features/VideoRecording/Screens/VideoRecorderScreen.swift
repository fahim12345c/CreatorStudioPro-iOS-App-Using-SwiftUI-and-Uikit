import SwiftUI

struct VideoRecorderScreen: View {
    @StateObject private var viewModel = VideoRecorderViewModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.cameraUnavailable {
                VStack(spacing: 16) {
                    Image(systemName: "camera.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.appSecondaryText)
                    Text("Camera Unavailable")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Camera hardware is not available on this device.")
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                CameraPreview(cameraService: viewModel.cameraService)
                    .ignoresSafeArea()

                VStack {
                    HStack {
                        Button(action: { viewModel.showLibrary = true }) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: viewModel.cameraService.switchCamera) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)

                    Spacer()

                    VStack(spacing: 16) {
                        if viewModel.isRecording {
                            RecordingTimerView(duration: viewModel.videoRecorderService.recordingDuration)
                        }
                        RecordButton(
                            isRecording: viewModel.isRecording,
                            action: viewModel.toggleRecording
                        )
                        .opacity(viewModel.canRecord ? 1 : 0.4)
                        .disabled(!viewModel.canRecord)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Video Recorder")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Camera Permission Required", isPresented: $viewModel.permissionDenied) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enable camera access in Settings to record video.")
        }
        .onAppear { viewModel.startCamera() }
        .onDisappear { viewModel.stopCamera() }
        .fullScreenCover(isPresented: $viewModel.showLibrary) {
            VideoLibraryScreen()
        }
    }
}
