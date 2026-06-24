import SwiftUI

struct VideoPlayerScreen: View {
    let video: VideoModel
    @StateObject private var viewModel = MediaPlayerViewModel()

    var body: some View {
        VStack(spacing: 0) {
            PlayerPreview(playerService: viewModel.videoPlayerService)
                .aspectRatio(16 / 9, contentMode: .fit)
                .onTapGesture { viewModel.togglePlayPause() }

            VStack(spacing: 20) {
                SeekBarView(
                    currentTime: $viewModel.currentTime,
                    duration: viewModel.duration,
                    onSeek: viewModel.seek
                )

                PlaybackControls(
                    isPlaying: $viewModel.isPlaying,
                    onPlay: viewModel.play,
                    onPause: viewModel.pause,
                    onSkipBackward: viewModel.skipBackward,
                    onSkipForward: viewModel.skipForward
                )

                HStack {
                    Label(video.formattedDuration, systemImage: "clock")
                    Spacer()
                    Label(TimeFormatter.formatFileSize(video.fileSize), systemImage: "arrow.down.circle")
                }
                .font(.caption)
                .foregroundColor(.appSecondaryText)
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Video Player")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadVideo(video.url) }
    }
}
