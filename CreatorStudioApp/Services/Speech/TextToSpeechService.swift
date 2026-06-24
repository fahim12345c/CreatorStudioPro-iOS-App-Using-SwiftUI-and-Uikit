import Combine
import AVFoundation

protocol TextToSpeechServiceDelegate: AnyObject {
    func textToSpeechServiceDidStartSpeaking(_ service: TextToSpeechService)
    func textToSpeechServiceDidPauseSpeaking(_ service: TextToSpeechService)
    func textToSpeechServiceDidContinueSpeaking(_ service: TextToSpeechService)
    func textToSpeechServiceDidFinishSpeaking(_ service: TextToSpeechService)
}

final class TextToSpeechService: NSObject {
    weak var delegate: TextToSpeechServiceDelegate?

    @Published var isSpeaking = false
    @Published var isPaused = false

    private let synthesizer = AVSpeechSynthesizer()
    private var settings: SpeechSettingsModel = .default

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, settings: SpeechSettingsModel? = nil) {
        let speechSettings = settings ?? self.settings
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = speechSettings.voice
        utterance.pitchMultiplier = speechSettings.pitch
        utterance.rate = speechSettings.rate

        synthesizer.speak(utterance)
    }

    func pauseSpeaking() {
        synthesizer.pauseSpeaking(at: .word)
    }

    func continueSpeaking() {
        synthesizer.continueSpeaking()
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func setSettings(_ settings: SpeechSettingsModel) {
        self.settings = settings
    }

    static func availableVoices() -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
    }

    static func availableLanguages() -> [String] {
        AVSpeechSynthesisVoice.speechVoices().map(\.language)
    }
}

extension TextToSpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
            self.isPaused = false
            self.delegate?.textToSpeechServiceDidStartSpeaking(self)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPaused = true
            self.delegate?.textToSpeechServiceDidPauseSpeaking(self)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPaused = false
            self.delegate?.textToSpeechServiceDidContinueSpeaking(self)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.isPaused = false
            self.delegate?.textToSpeechServiceDidFinishSpeaking(self)
        }
    }
}
