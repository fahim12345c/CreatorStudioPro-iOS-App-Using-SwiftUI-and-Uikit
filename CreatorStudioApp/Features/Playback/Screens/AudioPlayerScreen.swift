import SwiftUI

struct AudioPlayerScreen: View {
    let audio: AudioRecordingModel
    @StateObject private var viewModel = MediaPlayerViewModel()

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.appPrimary)

            VStack(spacing: 8) {
                Text(audio.fileName)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(audio.formattedDuration)
                    .font(.subheadline)
                    .foregroundColor(.appSecondaryText)
            }

            SeekBarView(
                currentTime: $viewModel.currentTime,
                duration: viewModel.duration,
                onSeek: viewModel.seek
            )
            .padding(.horizontal)

            PlaybackControls(
                isPlaying: $viewModel.isPlaying,
                onPlay: viewModel.play,
                onPause: viewModel.pause,
                onSkipBackward: viewModel.skipBackward,
                onSkipForward: viewModel.skipForward
            )

            Spacer()
        }
        .navigationTitle("Audio Player")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadAudio(audio.url) }
    }
}
