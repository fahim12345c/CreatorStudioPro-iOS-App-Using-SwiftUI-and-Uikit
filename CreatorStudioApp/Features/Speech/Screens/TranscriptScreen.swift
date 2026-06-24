import SwiftUI

struct TranscriptScreen: View {
    @StateObject private var viewModel = SpeechViewModel()

    var body: some View {
        VStack(spacing: 0) {
            TranscriptView(text: viewModel.transcriptText, isActive: viewModel.isRecognizing)

            SpeechControlPanel(
                isRecognizing: viewModel.isRecognizing,
                onToggleRecognition: viewModel.toggleRecognition
            )
            .padding()

            if !viewModel.transcriptHistory.isEmpty {
                List {
                    Section("Transcript History") {
                        ForEach(viewModel.transcriptHistory) { history in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(history.title ?? "Transcript")
                                    .font(.headline)
                                Text(history.fullText.prefix(100) + "...")
                                    .font(.caption)
                                    .foregroundColor(.appSecondaryText)
                                Text(TimeFormatter.formatRelativeDate(history.createdAt))
                                    .font(.caption2)
                                    .foregroundColor(.appSecondaryText)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Speech to Text")
    }
}
