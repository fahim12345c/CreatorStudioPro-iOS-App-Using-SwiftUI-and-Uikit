import Foundation

final class FileManagerHelper {
    static let shared = FileManagerHelper()

    private let fileManager = FileManager.default

    private init() {
        createDefaultDirectories()
    }

    var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    var recordingsDirectory: URL {
        documentsDirectory.appendingPathComponent(FileNames.recordingsFolder)
    }

    var exportsDirectory: URL {
        documentsDirectory.appendingPathComponent(FileNames.exportsFolder)
    }

    var audioDirectory: URL {
        documentsDirectory.appendingPathComponent(FileNames.audioFolder)
    }

    var transcriptsDirectory: URL {
        documentsDirectory.appendingPathComponent(FileNames.transcriptsFolder)
    }

    var thumbnailsDirectory: URL {
        documentsDirectory.appendingPathComponent(FileNames.thumbnailsFolder)
    }

    var cacheDirectory: URL {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return caches.appendingPathComponent(FileNames.cacheFolder)
    }

    private func createDefaultDirectories() {
        let directories = [
            recordingsDirectory,
            exportsDirectory,
            audioDirectory,
            transcriptsDirectory,
            thumbnailsDirectory,
            cacheDirectory
        ]
        for directory in directories {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }

    func removeFile(at url: URL) throws {
        guard fileExists(at: url) else { return }
        try fileManager.removeItem(at: url)
    }

    func copyFile(from source: URL, to destination: URL) throws {
        try fileManager.copyItem(at: source, to: destination)
    }

    func moveFile(from source: URL, to destination: URL) throws {
        try fileManager.moveItem(at: source, to: destination)
    }

    func contentsOfDirectory(at url: URL) -> [URL] {
        (try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? []
    }

    func clearCache() throws {
        let contents = contentsOfDirectory(at: cacheDirectory)
        for url in contents {
            try removeFile(at: url)
        }
    }

    func totalCacheSize() -> UInt64 {
        contentsOfDirectory(at: cacheDirectory).reduce(0) { $0 + $1.fileSize }
    }
}
