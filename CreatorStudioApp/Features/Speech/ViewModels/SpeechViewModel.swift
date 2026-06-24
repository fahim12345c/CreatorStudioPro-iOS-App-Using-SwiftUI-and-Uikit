import SwiftUI
import Combine

@MainActor
final class SpeechViewModel: ObservableObject {
    let recognitionService = SpeechRecognitionService()
    let ttsService = TextToSpeechService()

    @Published var transcriptText = ""
    @Published var transcriptHistory: [TranscriptHistory] = []
    @Published var isRecognizing = false
    @Published var isSpeaking = false
    @Published var ttsText = ""
    @Published var speechSettings: SpeechSettingsModel = .default
    @Published var showSettings = false

    init() {
        recognitionService.delegate = self
        ttsService.delegate = self
        loadHistory()
    }

    func toggleRecognition() {
        if isRecognizing {
            recognitionService.stopRecognition()
            saveTranscript()
        } else {
            Task {
                let granted = await SpeechPermissionManager.shared.requestPermission()
                if granted {
                    recognitionService.startRecognition()
                }
            }
        }
        isRecognizing.toggle()
    }

    func speakText() {
        guard !ttsText.isEmpty else { return }
        if isSpeaking {
            ttsService.stopSpeaking()
        } else {
            ttsService.speak(ttsText, settings: speechSettings)
        }
    }

    func stopSpeaking() {
        ttsService.stopSpeaking()
    }

    private func saveTranscript() {
        guard !transcriptText.isEmpty else { return }
        let segments = [TranscriptModel(text: transcriptText, isFinal: true)]
        let history = TranscriptHistory(segments: segments)
        transcriptHistory.insert(history, at: 0)
        StorageManager.shared.saveTranscript(text: transcriptText)
    }

    private func loadHistory() {
        let urls = StorageManager.shared.loadAllTranscripts()
        transcriptHistory = urls.compactMap { url in
            guard let text = try? String(contentsOf: url) else { return nil }
            let segments = [TranscriptModel(text: text, isFinal: true)]
            return TranscriptHistory(segments: segments, createdAt: url.creationDate ?? Date())
        }
    }
}

extension SpeechViewModel: SpeechRecognitionServiceDelegate {
    func speechRecognitionService(_ service: SpeechRecognitionService, didTranscribe text: String, isFinal: Bool) {
        transcriptText = text
    }

    func speechRecognitionService(_ service: SpeechRecognitionService, didUpdateAvailability available: Bool) {}

    func speechRecognitionService(_ service: SpeechRecognitionService, didFailWith error: Error) {
        isRecognizing = false
    }
}

extension SpeechViewModel: TextToSpeechServiceDelegate {
    func textToSpeechServiceDidStartSpeaking(_ service: TextToSpeechService) { isSpeaking = true }
    func textToSpeechServiceDidPauseSpeaking(_ service: TextToSpeechService) { isSpeaking = false }
    func textToSpeechServiceDidContinueSpeaking(_ service: TextToSpeechService) { isSpeaking = true }
    func textToSpeechServiceDidFinishSpeaking(_ service: TextToSpeechService) { isSpeaking = false }
}
