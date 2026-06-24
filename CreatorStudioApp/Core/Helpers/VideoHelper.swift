import AVFoundation
import UIKit

enum VideoHelper {
    static func generateThumbnail(for url: URL, at time: CMTime = .zero) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        var actualTime = CMTime.zero
        guard let cgImage = try? generator.copyCGImage(at: time, actualTime: &actualTime) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    static func duration(for url: URL) -> CMTime {
        let asset = AVAsset(url: url)
        return asset.duration
    }

    static func naturalSize(for url: URL) -> CGSize? {
        let asset = AVAsset(url: url)
        return asset.tracks(withMediaType: .video).first?.naturalSize
    }

    static func videoOrientation(for url: URL) -> UIInterfaceOrientation {
        let asset = AVAsset(url: url)
        guard let track = asset.tracks(withMediaType: .video).first else {
            return .portrait
        }
        let transform = track.preferredTransform
        let angle = atan2(transform.b, transform.a)

        switch angle {
        case 0:
            return .portrait
        case .pi / 2:
            return .landscapeLeft
        case -.pi / 2:
            return .landscapeRight
        case .pi, -.pi:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }

    static func isVideoPortrait(for url: URL) -> Bool {
        let orientation = videoOrientation(for: url)
        return orientation == .portrait || orientation == .portraitUpsideDown
    }
}
