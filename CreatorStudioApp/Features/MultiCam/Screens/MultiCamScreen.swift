import SwiftUI

struct MultiCamScreen: View {
    @StateObject private var viewModel = MultiCamViewModel()

    var body: some View {
        VStack {
            if viewModel.multiCamService.isMultiCamSupported {
                MultiCamPreview(multiCamService: viewModel.multiCamService)
                    .ignoresSafeArea()
                    .overlay(alignment: .bottom) {
                        MultiCamControls(
                            isRunning: viewModel.isRunning,
                            onToggle: viewModel.toggleMultiCam
                        )
                        .padding(.bottom, 40)
                    }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "camera.metering.unknown")
                        .font(.system(size: 60))
                        .foregroundColor(.appSecondaryText)
                    Text("Multi-Camera not supported")
                        .font(.headline)
                    Text("This device does not support simultaneous front and back camera capture.")
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            }
        }
        .navigationTitle("Multi-Cam")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Camera Permission Required", isPresented: $viewModel.permissionDenied) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enable camera access in Settings to use Multi-Camera.")
        }
    }
}
