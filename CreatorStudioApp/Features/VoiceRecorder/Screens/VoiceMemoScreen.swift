import SwiftUI

struct VoiceMemoScreen: View {
    @StateObject private var viewModel = VoiceMemoViewModel()

    var body: some View {
        VStack(spacing: 20) {
            AudioLevelView(averagePower: viewModel.averagePower, isRecording: viewModel.isRecording)
                .frame(height: 120)
                .padding(.top)

            if viewModel.isRecording {
                Text(TimeFormatter.formatTimeInterval(viewModel.currentTime))
                    .font(.system(size: 48, design: .monospaced))
                    .foregroundColor(.red)
            }

            RecordingControls(
                isRecording: viewModel.isRecording,
                onStart: viewModel.startRecording,
                onStop: viewModel.stopRecording
            )

            List {
                ForEach(viewModel.recordings) { recording in
                    Button(action: { viewModel.playRecording(recording) }) {
                        HStack {
                            Image(systemName: viewModel.isPlaying && viewModel.selectedRecording?.id == recording.id
                                ? "stop.circle.fill" : "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(.appPrimary)
                            VStack(alignment: .leading) {
                                Text(recording.fileName)
                                    .font(.subheadline)
                                Text(recording.formattedDuration)
                                    .font(.caption)
                                    .foregroundColor(.appSecondaryText)
                            }
                            Spacer()
                            Text(TimeFormatter.formatRelativeDate(recording.creationDate))
                                .font(.caption)
                                .foregroundColor(.appSecondaryText)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.deleteRecording(recording)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Voice Memos")
        .alert("Microphone Access Required", isPresented: $viewModel.permissionDenied) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enable microphone access in Settings to record voice memos.")
        }
    }
}
