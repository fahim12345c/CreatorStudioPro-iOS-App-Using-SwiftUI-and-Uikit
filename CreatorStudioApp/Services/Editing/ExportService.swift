import Combine
import AVFoundation
import UIKit

final class ExportService: ObservableObject {
    @Published var isExporting = false
    @Published var progress: Float = 0
    @Published var exportCompleted = false

    enum ExportFormat: String, CaseIterable {
        case mp4 = "MP4"
        case mov = "MOV"

        var fileExtension: String {
            rawValue.lowercased()
        }

        var fileType: AVFileType {
            switch self {
            case .mp4: return .mp4
            case .mov: return .mov
            }
        }
    }

    func exportVideo(at url: URL, format: ExportFormat = .mp4, quality: String = AVAssetExportPresetHighestQuality) async -> URL? {
        let asset = AVAsset(url: url)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: quality) else {
            return nil
        }

        let outputURL = FileManagerHelper.shared.exportsDirectory
            .appendingPathComponent(FileNames.uniqueFilename(extension: format.fileExtension))

        exportSession.outputURL = outputURL
        exportSession.outputFileType = format.fileType
        exportSession.shouldOptimizeForNetworkUse = true

        DispatchQueue.main.async { self.isExporting = true }

        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.progress = exportSession.progress
        }

        await exportSession.export()

        timer.invalidate()

        DispatchQueue.main.async {
            self.isExporting = false
            self.exportCompleted = exportSession.status == .completed
        }

        return exportSession.status == .completed ? outputURL : nil
    }

    func exportPhoto(_ image: UIImage, format: ExportFormat = .mp4) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        let outputURL = FileManagerHelper.shared.exportsDirectory
            .appendingPathComponent(FileNames.uniqueFilename(extension: "jpg"))
        try? data.write(to: outputURL)
        return outputURL
    }

    func exportAudio(at url: URL, format: String = "m4a") -> URL? {
        let outputURL = FileManagerHelper.shared.exportsDirectory
            .appendingPathComponent(FileNames.uniqueFilename(extension: format))
        try? FileManagerHelper.shared.copyFile(from: url, to: outputURL)
        return outputURL
    }

    func reset() {
        isExporting = false
        progress = 0
        exportCompleted = false
    }
}
