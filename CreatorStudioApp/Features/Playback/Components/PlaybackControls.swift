import SwiftUI

struct PlaybackControls: View {
    @Binding var isPlaying: Bool
    let onPlay: () -> Void
    let onPause: () -> Void
    let onSkipBackward: () -> Void
    let onSkipForward: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            Button(action: onSkipBackward) {
                Image(systemName: "gobackward.10")
                    .font(.title)
            }

            Button(action: {
                isPlaying ? onPause() : onPlay()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.appPrimary)
            }

            Button(action: onSkipForward) {
                Image(systemName: "goforward.10")
                    .font(.title)
            }
        }
        .foregroundColor(.appText)
    }
}
