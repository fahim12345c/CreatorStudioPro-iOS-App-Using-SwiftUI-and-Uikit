import Foundation

final class StorageManager {
    static let shared = StorageManager()
    private let helper = FileManagerHelper.shared

    private init() {}

    func savePhoto(_ data: Data, name: String? = nil) -> URL? {
        let fileName = name ?? FileNames.uniqueFilename(extension: "jpg")
        let fileURL = helper.recordingsDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }

    func saveVideo(from sourceURL: URL, name: String? = nil) -> URL? {
        let fileName = name ?? FileNames.uniqueFilename(extension: "mp4")
        let destURL = helper.recordingsDirectory.appendingPathComponent(fileName)
        do {
            try helper.copyFile(from: sourceURL, to: destURL)
            return destURL
        } catch {
            return nil
        }
    }

    func saveAudio(from sourceURL: URL, name: String? = nil) -> URL? {
        let fileName = name ?? FileNames.uniqueFilename(extension: "m4a")
        let destURL = helper.audioDirectory.appendingPathComponent(fileName)
        do {
            try helper.copyFile(from: sourceURL, to: destURL)
            return destURL
        } catch {
            return nil
        }
    }

    func saveTranscript(text: String, name: String? = nil) -> URL? {
        let fileName = name ?? FileNames.uniqueFilename(extension: "txt")
        let fileURL = helper.transcriptsDirectory.appendingPathComponent(fileName)
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }

    func loadAllRecordings() -> [URL] {
        helper.contentsOfDirectory(at: helper.recordingsDirectory)
    }

    func loadAllAudioFiles() -> [URL] {
        helper.contentsOfDirectory(at: helper.audioDirectory)
    }

    func loadAllTranscripts() -> [URL] {
        helper.contentsOfDirectory(at: helper.transcriptsDirectory)
    }

    func deleteFile(at url: URL) {
        try? helper.removeFile(at: url)
    }

    func clearAllData() {
        try? helper.removeFile(at: helper.recordingsDirectory)
        try? helper.removeFile(at: helper.audioDirectory)
        try? helper.removeFile(at: helper.transcriptsDirectory)
        try? helper.removeFile(at: helper.exportsDirectory)
        try? helper.removeFile(at: helper.thumbnailsDirectory)
    }

    var totalStorageUsed: UInt64 {
        let dirs = [
            helper.recordingsDirectory,
            helper.audioDirectory,
            helper.transcriptsDirectory,
            helper.exportsDirectory
        ]
        return dirs.reduce(0) { total, dir in
            total + helper.contentsOfDirectory(at: dir).reduce(0) { $0 + $1.fileSize }
        }
    }
}
