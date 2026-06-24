import AVFoundation
import VideoToolbox
import UIKit

final class StreamEncoder {
    enum EncoderError: LocalizedError {
        case compressionFailed
        case invalidConfiguration

        var errorDescription: String? {
            switch self {
            case .compressionFailed: return "Video compression failed"
            case .invalidConfiguration: return "Invalid encoder configuration"
            }
        }
    }

    func encodeVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> Data? {
        guard let imageBuffer = sampleBuffer.imageBuffer else { return nil }

        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }

        let uiImage = UIImage(cgImage: cgImage)
        return uiImage.jpegData(compressionQuality: 0.8)
    }

    func encodeAudioBuffer(_ buffer: AVAudioPCMBuffer) -> Data? {
        let frameLength = Int(buffer.frameLength)
        guard let channelData = buffer.floatChannelData else { return nil }

        var data = Data()
        for frame in 0..<frameLength {
            let sample = channelData[0][frame]
            var sampleBytes = sample.bitPattern
            data.append(Data(bytes: &sampleBytes, count: MemoryLayout<UInt32>.size))
        }

        return data
    }

    func createVideoFormatDescription(from sampleBuffer: CMSampleBuffer) -> CMFormatDescription? {
        sampleBuffer.formatDescription
    }
}
