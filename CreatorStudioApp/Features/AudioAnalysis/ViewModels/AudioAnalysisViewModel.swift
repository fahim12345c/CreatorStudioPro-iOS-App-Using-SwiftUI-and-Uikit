import SwiftUI
import Combine
import AVFoundation

@MainActor
final class AudioAnalysisViewModel: ObservableObject {
    let engineService = AudioEngineService()
    let analyzer = AudioAnalyzer()

    @Published var isAnalyzing = false
    @Published var averagePower: Float = 0
    @Published var peakPower: Float = 0
    @Published var frequency: Float = 0
    @Published var amplitude: Float = 0
    @Published var isSilent = true
    @Published var waveform: [Float] = Array(repeating: 0, count: 100)
    @Published var errorMessage: String?

    init() {
        engineService.delegate = self
    }

    func startAnalysis() {
        errorMessage = nil
        Task {
            let granted = await MicrophonePermissionManager.shared.requestPermission()
            if granted {
                do {
                    try engineService.startEngine()
                    isAnalyzing = true
                } catch {
                    errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
                    isAnalyzing = false
                }
            } else {
                errorMessage = "Microphone permission is required for audio analysis."
            }
        }
    }

    func stopAnalysis() {
        engineService.stopEngine()
        isAnalyzing = false
    }
}

extension AudioAnalysisViewModel: AudioEngineServiceDelegate {
    func audioEngineService(_ service: AudioEngineService, didCaptureBuffer buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        let result = analyzer.analyzeBuffer(buffer)
        DispatchQueue.main.async {
            self.averagePower = result.averagePower
            self.peakPower = result.peakPower
            self.frequency = result.frequency
            self.amplitude = result.amplitude
            self.isSilent = result.isSilent
            self.waveform = self.analyzer.computeWaveform(from: buffer, targetSamples: 100)
        }
    }

    func audioEngineService(_ service: AudioEngineService, didUpdateAveragePower power: Float) {
        averagePower = power
    }

    func audioEngineService(_ service: AudioEngineService, didFailWith error: Error) {
        isAnalyzing = false
        errorMessage = error.localizedDescription
    }
}
