import AVFoundation

struct SpeechSettingsModel: Codable {
    var language: String
    var pitch: Float
    var rate: Float
    var voiceIdentifier: String?

    static let `default` = SpeechSettingsModel(
        language: "en-US",
        pitch: 1.0,
        rate: AVSpeechUtteranceDefaultSpeechRate,
        voiceIdentifier: nil
    )

    var voice: AVSpeechSynthesisVoice? {
        if let id = voiceIdentifier {
            return AVSpeechSynthesisVoice(identifier: id)
        }
        return AVSpeechSynthesisVoice(language: language)
    }
}
