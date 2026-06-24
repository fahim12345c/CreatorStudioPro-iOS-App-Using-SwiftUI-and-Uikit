import Foundation

extension URL {
    var attributes: [FileAttributeKey: Any]? {
        try? FileManager.default.attributesOfItem(atPath: path)
    }

    var fileSize: UInt64 {
        attributes?[.size] as? UInt64 ?? 0
    }

    var fileSizeString: String {
        let byteCount = Int64(fileSize)
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: byteCount)
    }

    var creationDate: Date? {
        attributes?[.creationDate] as? Date
    }

    var isMediaFile: Bool {
        let mediaExtensions = ["mp4", "mov", "m4a", "wav", "aac", "jpg", "jpeg", "png", "heic"]
        return mediaExtensions.contains(pathExtension.lowercased())
    }
}
