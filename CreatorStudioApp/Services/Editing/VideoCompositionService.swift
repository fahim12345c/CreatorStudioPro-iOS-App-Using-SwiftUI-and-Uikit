import AVFoundation
import UIKit

final class VideoCompositionService {
    func trimVideo(at url: URL, startTime: CMTime, endTime: CMTime) async -> URL? {
        let asset = AVAsset(url: url)
        let composition = AVMutableComposition()

        guard let track = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else { return nil }

        guard let assetTrack = asset.tracks(withMediaType: .video).first else { return nil }

        do {
            let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
            try track.insertTimeRange(timeRange, of: assetTrack, at: .zero)

            if let audioTrack = asset.tracks(withMediaType: .audio).first,
               let audioCompositionTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
               ) {
                try audioCompositionTrack.insertTimeRange(timeRange, of: audioTrack, at: .zero)
            }

            return try await exportComposition(composition, preset: AVAssetExportPresetHighestQuality)
        } catch {
            Logger.error("Failed to trim video", category: .service, error: error)
            return nil
        }
    }

    func mergeVideos(urls: [URL]) async -> URL? {
        let composition = AVMutableComposition()
        var currentTime: CMTime = .zero

        for url in urls {
            let asset = AVAsset(url: url)

            guard let videoTrack = asset.tracks(withMediaType: .video).first,
                  let compositionVideoTrack = composition.addMutableTrack(
                    withMediaType: .video,
                    preferredTrackID: kCMPersistentTrackID_Invalid
                  ) else { continue }

            do {
                try compositionVideoTrack.insertTimeRange(
                    CMTimeRange(start: .zero, duration: asset.duration),
                    of: videoTrack,
                    at: currentTime
                )

                if let audioTrack = asset.tracks(withMediaType: .audio).first,
                   let compositionAudioTrack = composition.addMutableTrack(
                    withMediaType: .audio,
                    preferredTrackID: kCMPersistentTrackID_Invalid
                   ) {
                    try compositionAudioTrack.insertTimeRange(
                        CMTimeRange(start: .zero, duration: asset.duration),
                        of: audioTrack,
                        at: currentTime
                    )
                }

                currentTime = CMTimeAdd(currentTime, asset.duration)
            } catch {
                Logger.error("Failed to merge video", category: .service, error: error)
                return nil
            }
        }

        return try? await exportComposition(composition, preset: AVAssetExportPresetHighestQuality)
    }

    func replaceAudio(inVideo videoURL: URL, withAudio audioURL: URL) async -> URL? {
        let videoAsset = AVAsset(url: videoURL)
        let audioAsset = AVAsset(url: audioURL)
        let composition = AVMutableComposition()

        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first,
              let compositionVideoTrack = composition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: kCMPersistentTrackID_Invalid
              ),
              let audioTrack = audioAsset.tracks(withMediaType: .audio).first,
              let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
              ) else { return nil }

        do {
            try compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: videoAsset.duration),
                of: videoTrack,
                at: .zero
            )
            try compositionAudioTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: videoAsset.duration),
                of: audioTrack,
                at: .zero
            )

            return try await exportComposition(composition, preset: AVAssetExportPresetHighestQuality)
        } catch {
            Logger.error("Failed to replace audio", category: .service, error: error)
            return nil
        }
    }

    private func exportComposition(_ composition: AVMutableComposition, preset: String) async throws -> URL? {
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: preset
        ) else { return nil }

        let outputURL = FileManagerHelper.shared.exportsDirectory
            .appendingPathComponent(FileNames.uniqueFilename(extension: "mp4"))
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true

        await exportSession.export()

        return exportSession.status == .completed ? outputURL : nil
    }
}
