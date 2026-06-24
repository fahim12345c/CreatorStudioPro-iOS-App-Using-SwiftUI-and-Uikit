import AVFoundation

enum AudioHelper {
    static func duration(for url: URL) -> TimeInterval {
        let asset = AVAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }

    static func waveformData(from url: URL, samplesPerSecond: Int = 100) -> [Float] {
        let asset = AVAsset(url: url)
        guard let reader = try? AVAssetReader(asset: asset),
              let track = asset.tracks(withMediaType: .audio).first else {
            return []
        }

        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]

        let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        reader.add(output)
        reader.startReading()

        var samples: [Float] = []
        let duration = CMTimeGetSeconds(asset.duration)
        let totalSamples = Int(duration * Double(samplesPerSecond))
        var sampleCount = 0

        while reader.status == .reading, sampleCount < totalSamples {
            guard let buffer = output.copyNextSampleBuffer(),
                  let blockBuffer = CMSampleBufferGetDataBuffer(buffer) else {
                continue
            }

            var length = 0
            var dataPointer: UnsafeMutablePointer<Int8>?
            CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &dataPointer)

            guard let data = dataPointer else { continue }
            let samplesInBuffer = length / 2
            let sampleArray = UnsafeBufferPointer(start: data, count: samplesInBuffer)

            var maxVal: Float = 0
            for i in 0..<samplesInBuffer {
                let val = abs(Float(sampleArray[i * 2]) / Float(Int16.max))
                maxVal = max(maxVal, val)
            }

            samples.append(maxVal)
            sampleCount += 1
        }

        reader.cancelReading()
        return samples
    }

    static func averagePower(from url: URL) -> Float {
        let samples = waveformData(from: url, samplesPerSecond: 10)
        guard !samples.isEmpty else { return 0 }
        return samples.reduce(0, +) / Float(samples.count)
    }
}
