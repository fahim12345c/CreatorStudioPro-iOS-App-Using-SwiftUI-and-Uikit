import AVFoundation
import Accelerate

final class AudioAnalyzer {
    struct AnalysisResult {
        let averagePower: Float
        let peakPower: Float
        let frequency: Float
        let amplitude: Float
        let rms: Float
        let isSilent: Bool
    }

    func analyzeBuffer(_ buffer: AVAudioPCMBuffer) -> AnalysisResult {
        let frameLength = buffer.frameLength
        guard let channelData = buffer.floatChannelData?[0] else {
            return AnalysisResult(averagePower: 0, peakPower: 0, frequency: 0, amplitude: 0, rms: 0, isSilent: true)
        }

        var sum: Float = 0
        var peak: Float = 0

        for i in 0..<Int(frameLength) {
            let sample = abs(channelData[i])
            sum += sample * sample
            peak = max(peak, sample)
        }

        let rms = sqrt(sum / Float(frameLength))
        let db = 20 * log10(rms + 0.0001)
        let peakDb = 20 * log10(peak + 0.0001)
        let frequency = estimateFrequency(from: channelData, count: Int(frameLength))
        let amplitude = rms

        return AnalysisResult(
            averagePower: db,
            peakPower: peakDb,
            frequency: frequency,
            amplitude: amplitude,
            rms: rms,
            isSilent: db < -50
        )
    }

    func computeWaveform(from buffer: AVAudioPCMBuffer, targetSamples: Int) -> [Float] {
        let frameLength = Int(buffer.frameLength)
        guard let data = buffer.floatChannelData?[0] else { return [] }

        let samplesPerSegment = max(1, frameLength / targetSamples)
        var waveform: [Float] = []

        for i in 0..<targetSamples {
            let start = i * samplesPerSegment
            let end = min(start + samplesPerSegment, frameLength)
            var maxVal: Float = 0

            for j in start..<end {
                let val = abs(data[j])
                maxVal = max(maxVal, val)
            }
            waveform.append(maxVal)
        }

        return waveform
    }

    private func estimateFrequency(from data: UnsafeMutablePointer<Float>, count: Int) -> Float {
        guard count > 1 else { return 0 }

        var zeroCrossings = 0
        for i in 1..<count {
            if data[i - 1] >= 0 && data[i] < 0 {
                zeroCrossings += 1
            }
        }

        let frequency = Float(zeroCrossings) / 2.0
        return frequency
    }
}
