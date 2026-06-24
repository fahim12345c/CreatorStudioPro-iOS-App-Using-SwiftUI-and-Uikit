import SwiftUI

struct CameraScreen: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var zoom: CGFloat = 1.0

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
                    .gesture(
                        MagnificationGesture()
                            .onChanged { scale in
                                zoom = max(1, min(scale, 5))
                                viewModel.setZoom(zoom)
                            }
                    )
                    .onTapGesture { location in
                        viewModel.cameraService.focus(at: location)
                    }

                VStack {
                    CameraToolbar(
                        onSwitchCamera: viewModel.switchCamera,
                        onToggleTorch: viewModel.toggleTorch,
                        onShowGallery: { viewModel.showGallery = true },
                        onShowSettings: { viewModel.showSettings = true },
                        torchOn: viewModel.cameraService.isTorchOn,
                        cameraPosition: viewModel.cameraService.cameraPosition
                    )

                    Spacer()

                    CameraControlsView(
                        currentMode: $viewModel.currentMode,
                        isRecording: viewModel.isVideoRecording,
                        isPaused: viewModel.isPaused,
                        onCapture: viewModel.capturePhoto,
                        onToggleRecording: viewModel.toggleRecording,
                        onPause: viewModel.pauseRecording,
                        onResume: viewModel.resumeRecording,
                        recordingDuration: viewModel.videoRecordingDuration,
                        canRecord: viewModel.cameraService.isConfigured
                    )
                }
            }
        }
        .onAppear { viewModel.startCamera() }
        .onDisappear { viewModel.stopCamera() }
        .sheet(isPresented: $viewModel.showGallery) {
            GalleryScreen()
        }
        .alert("Camera Permission Required", isPresented: $viewModel.permissionDenied) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enable camera access in Settings to use this feature.")
        }
        .alert("Save Video", isPresented: $viewModel.showSaveAlert) {
            Button("Yes") { viewModel.saveVideo() }
            Button("No", role: .destructive) { viewModel.discardVideo() }
        } message: {
            Text("Would you like to save this recording?")
        }
    }
}
