import Foundation
import UIKit

struct PhotoModel: Identifiable, Codable {
    let id: UUID
    let url: URL
    let creationDate: Date
    let fileSize: UInt64

    var fileName: String {
        url.lastPathComponent
    }

    var thumbnail: UIImage? {
        UIImage(contentsOfFile: url.path)
    }

    init(id: UUID = UUID(), url: URL, creationDate: Date = Date(), fileSize: UInt64? = nil) {
        self.id = id
        self.url = url
        self.creationDate = creationDate
        self.fileSize = fileSize ?? url.fileSize
    }
}
