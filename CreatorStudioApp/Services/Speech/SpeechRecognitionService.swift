import Combine
import Speech
import AVFoundation

protocol SpeechRecognitionServiceDelegate: AnyObject {
    func speechRecognitionService(_ service: SpeechRecognitionService, didTranscribe text: String, isFinal: Bool)
    func speechRecognitionService(_ service: SpeechRecognitionService, didUpdateAvailability available: Bool)
    func speechRecognitionService(_ service: SpeechRecognitionService, didFailWith error: Error)
}

final class SpeechRecognitionService: NSObject {
    weak var delegate: SpeechRecognitionServiceDelegate?

    @Published var isRecognizing = false
    @Published var isAvailable = false
    @Published var transcript = ""

    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    override init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        super.init()
        checkAvailability()
    }

    private func checkAvailability() {
        guard let recognizer = speechRecognizer else {
            isAvailable = false
            return
        }
        isAvailable = recognizer.isAvailable
        delegate?.speechRecognitionService(self, didUpdateAvailability: recognizer.isAvailable)
    }

    func startRecognition() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            delegate?.speechRecognitionService(self, didFailWith: SpeechError.notAvailable)
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            delegate?.speechRecognitionService(self, didFailWith: error)
            return
        }

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }

            if let result {
                let bestString = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.transcript = bestString
                    self.delegate?.speechRecognitionService(self, didTranscribe: bestString, isFinal: result.isFinal)
                }
            }

            if error != nil {
                self.stopRecognition()
            }
        }

        isRecognizing = true
    }

    func stopRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil
        isRecognizing = false
    }
}

enum SpeechError: LocalizedError {
    case notAvailable
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .notAvailable: return "Speech recognition is not available on this device"
        case .notAuthorized: return "Speech recognition permission not granted"
        }
    }
}
