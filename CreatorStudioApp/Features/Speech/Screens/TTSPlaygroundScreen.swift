import SwiftUI

struct TTSPlaygroundScreen: View {
    @StateObject private var viewModel = SpeechViewModel()
    @State private var showingVoicePicker = false

    var body: some View {
        VStack(spacing: 20) {
            TextEditor(text: $viewModel.ttsText)
                .frame(height: 150)
                .border(Color.appSecondaryBackground)
                .cornerRadius(8)
                .padding(.horizontal)
                .overlay(alignment: .topTrailing) {
                    if viewModel.ttsText.isEmpty {
                        Text("Enter text to speak...")
                            .foregroundColor(.appSecondaryText)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                    }
                }

            SpeechControlPanel(
                isRecognizing: viewModel.isSpeaking,
                onToggleRecognition: viewModel.speakText
            )

            Form {
                Section("Speech Settings") {
                    VStack {
                        Text("Pitch: \(viewModel.speechSettings.pitch, specifier: "%.1f")")
                        Slider(value: $viewModel.speechSettings.pitch, in: 0.5...2.0, step: 0.1)
                    }

                    VStack {
                        Text("Rate: \(viewModel.speechSettings.rate, specifier: "%.2f")")
                        Slider(value: $viewModel.speechSettings.rate, in: 0.1...1.0, step: 0.05)
                    }
                }
            }
        }
        .navigationTitle("Text to Speech")
    }
}
