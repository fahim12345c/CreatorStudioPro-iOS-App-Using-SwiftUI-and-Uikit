import SwiftUI
import AVFoundation

struct VideoEditorScreen: View {
    @StateObject private var viewModel = VideoEditorViewModel()
    @State private var playerService = VideoPlayerService()
    let videoURL: URL

    var body: some View {
        VStack(spacing: 0) {
            if let url = viewModel.sourceVideoURL {
                PlayerPreview(playerService: playerService)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .onAppear {
                        playerService.load(url: url)
                    }
            }

            VStack(spacing: 16) {
                TimelineView(
                    duration: viewModel.videoDuration,
                    startTime: viewModel.trimStartTime,
                    endTime: viewModel.trimEndTime,
                    onUpdateStart: viewModel.updateTrimStart,
                    onUpdateEnd: viewModel.updateTrimEnd
                )
                .frame(height: 60)
                .padding(.horizontal)

                HStack(spacing: 40) {
                    Text("Start: \(Int(CMTimeGetSeconds(viewModel.trimStartTime)))s")
                        .font(.caption)
                    Text("End: \(Int(CMTimeGetSeconds(viewModel.trimEndTime)))s")
                        .font(.caption)
                }
                .foregroundColor(.appSecondaryText)

                HStack(spacing: 20) {
                    Button(action: { Task { await viewModel.trimVideo() } }) {
                        Label("Trim", systemImage: "scissors")
                    }
                    .disabled(viewModel.isTrimming)
                    .buttonStyle(.bordered)

                    ExportButton(
                        isExporting: viewModel.isExporting,
                        progress: viewModel.exportService.progress,
                        onExport: viewModel.exportVideo
                    )
                    .disabled(viewModel.exportedURL == nil)
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("Video Editor")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadVideo(videoURL) }
        .alert("Export Complete", isPresented: $viewModel.showExporter) {
            Button("OK") {}
        } message: {
            Text("Video has been exported successfully.")
        }
    }
}
