import Foundation

struct AudioRecordingModel: Identifiable, Codable {
    let id: UUID
    let url: URL
    let creationDate: Date
    let duration: TimeInterval
    let fileSize: UInt64

    var fileName: String {
        url.lastPathComponent
    }

    var formattedDuration: String {
        TimeFormatter.formatTimeInterval(duration)
    }

    init(id: UUID = UUID(), url: URL, creationDate: Date = Date(), duration: TimeInterval, fileSize: UInt64? = nil) {
        self.id = id
        self.url = url
        self.creationDate = creationDate
        self.duration = duration
        self.fileSize = fileSize ?? url.fileSize
    }
}
