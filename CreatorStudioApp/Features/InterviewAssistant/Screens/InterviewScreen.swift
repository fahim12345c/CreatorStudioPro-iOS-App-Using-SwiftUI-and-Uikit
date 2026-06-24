import SwiftUI

struct InterviewScreen: View {
    @StateObject private var viewModel = InterviewViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    CameraPreview(cameraService: viewModel.sessionManager.cameraService)
                        .frame(height: UIScreen.main.bounds.height * 0.35)
                        .overlay(alignment: .topTrailing) {
                            FaceStatusView(faceCount: viewModel.faceCount)
                                .padding()
                        }

                    VStack(spacing: 12) {
                        LiveTranscriptView(text: viewModel.transcript)
                            .frame(maxHeight: .infinity)

                        AudioLevelView(averagePower: viewModel.audioLevel, isRecording: viewModel.isRecording)
                            .frame(height: 60)
                            .padding(.horizontal)

                        InterviewToolbar(
                            isSessionActive: viewModel.isSessionActive,
                            isRecording: viewModel.isRecording,
                            elapsedTime: viewModel.elapsedTime,
                            onStartSession: viewModel.startSession,
                            onStopSession: viewModel.stopSession,
                            onToggleRecording: viewModel.toggleRecording
                        )
                    }
                    .padding()
                    .background(Color.appBackground)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Interview Assistant")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
