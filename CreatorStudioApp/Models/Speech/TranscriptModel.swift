import Foundation

struct TranscriptModel: Identifiable, Codable {
    let id: UUID
    let text: String
    let timestamp: Date
    let isFinal: Bool
    let segmentIndex: Int

    init(id: UUID = UUID(), text: String, timestamp: Date = Date(), isFinal: Bool = false, segmentIndex: Int = 0) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.isFinal = isFinal
        self.segmentIndex = segmentIndex
    }
}

struct TranscriptHistory: Identifiable, Codable {
    let id: UUID
    let segments: [TranscriptModel]
    let createdAt: Date
    let title: String?

    var fullText: String {
        segments.map(\.text).joined(separator: " ")
    }

    init(id: UUID = UUID(), segments: [TranscriptModel], createdAt: Date = Date(), title: String? = nil) {
        self.id = id
        self.segments = segments
        self.createdAt = createdAt
        self.title = title
    }
}
