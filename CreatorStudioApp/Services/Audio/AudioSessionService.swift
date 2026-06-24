import AVFoundation
import UIKit

final class AudioSessionService {
    static let shared = AudioSessionService()

    private let session = AVAudioSession.sharedInstance()

    private init() {}

    var isActive: Bool {
        session.isOtherAudioPlaying
    }

    var currentRoute: AVAudioSessionRouteDescription {
        session.currentRoute
    }

    var availableInputs: [AVAudioSessionPortDescription]? {
        session.availableInputs
    }

    func configurePlayback() throws {
        try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try session.setActive(true)
    }

    func configureRecording() throws {
        try session.setCategory(.record, mode: .default)
        try session.setActive(true)
    }

    func configurePlayAndRecord() throws {
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)
    }

    func configureAudioAnalysis() throws {
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.allowBluetooth, .mixWithOthers])
        try session.setActive(true)
    }

    func enableSpeaker() throws {
        try session.overrideOutputAudioPort(.speaker)
    }

    func disableSpeaker() throws {
        try session.overrideOutputAudioPort(.none)
    }

    func setActive(_ active: Bool) throws {
        try session.setActive(active, options: .notifyOthersOnDeactivation)
    }

    func isBluetoothConnected() -> Bool {
        currentRoute.outputs.contains { port in
            port.portType == .bluetoothA2DP || port.portType == .bluetoothHFP || port.portType == .bluetoothLE
        }
    }

    func isHeadphonesConnected() -> Bool {
        currentRoute.outputs.contains { port in
            port.portType == .headphones || port.portType == .bluetoothA2DP
        }
    }
}
