import SwiftUI
import Combine
import AVFoundation

@MainActor
final class VideoEditorViewModel: ObservableObject {
    let compositionService = VideoCompositionService()
    let exportService = ExportService()

    @Published var sourceVideoURL: URL?
    @Published var trimStartTime: CMTime = .zero
    @Published var trimEndTime: CMTime = .zero
    @Published var videoDuration: CMTime = .zero
    @Published var isTrimming = false
    @Published var isExporting = false
    @Published var exportProgress: Float = 0
    @Published var exportedURL: URL?
    @Published var showExporter = false

    func loadVideo(_ url: URL) {
        sourceVideoURL = url
        let asset = AVAsset(url: url)
        videoDuration = asset.duration
        trimEndTime = videoDuration
    }

    func trimVideo() async {
        guard let url = sourceVideoURL else { return }
        isTrimming = true
        let result = await compositionService.trimVideo(at: url, startTime: trimStartTime, endTime: trimEndTime)
        isTrimming = false
        exportedURL = result
    }

    func exportVideo() {
        guard let url = exportedURL ?? sourceVideoURL else { return }
        isExporting = true
        Task {
            let result = await exportService.exportVideo(at: url)
            DispatchQueue.main.async {
                self.isExporting = false
                self.exportProgress = 1.0
                self.showExporter = result != nil
            }
        }
    }

    var formattedDuration: String {
        TimeFormatter.formatTimeInterval(CMTimeGetSeconds(videoDuration))
    }

    func updateTrimStart(_ seconds: Double) {
        trimStartTime = CMTime(seconds: seconds, preferredTimescale: 600)
    }

    func updateTrimEnd(_ seconds: Double) {
        trimEndTime = CMTime(seconds: seconds, preferredTimescale: 600)
    }
}
