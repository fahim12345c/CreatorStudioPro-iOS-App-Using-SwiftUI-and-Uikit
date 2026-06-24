import Foundation
import UIKit
import AVFoundation

struct VideoModel: Identifiable, Codable {
    let id: UUID
    let url: URL
    let creationDate: Date
    let duration: TimeInterval
    let fileSize: UInt64

    var fileName: String {
        url.lastPathComponent
    }

    var thumbnail: UIImage? {
        VideoHelper.generateThumbnail(for: url)
    }

    var formattedDuration: String {
        TimeFormatter.formatTimeInterval(duration)
    }

    init(id: UUID = UUID(), url: URL, creationDate: Date = Date(), duration: TimeInterval? = nil, fileSize: UInt64? = nil) {
        self.id = id
        self.url = url
        self.creationDate = creationDate
        self.duration = duration ?? CMTimeGetSeconds(VideoHelper.duration(for: url))
        self.fileSize = fileSize ?? url.fileSize
    }
}
