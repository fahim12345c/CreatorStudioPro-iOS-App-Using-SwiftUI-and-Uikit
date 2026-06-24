import Foundation

enum FileNames {
    static let recordingsFolder = "Recordings"
    static let exportsFolder = "Exports"
    static let audioFolder = "Audio"
    static let transcriptsFolder = "Transcripts"
    static let thumbnailsFolder = "Thumbnails"
    static let cacheFolder = "Cache"

    static func uniqueFilename(extension ext: String) -> String {
        UUID().uuidString + "." + ext
    }
}
