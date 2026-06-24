import Foundation

enum MediaType: String, CaseIterable, Identifiable {
    case photo = "Photo"
    case video = "Video"
    case audio = "Audio"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .photo: return "photo"
        case .video: return "video"
        case .audio: return "waveform"
        }
    }

    var fileExtensions: [String] {
        switch self {
        case .photo: return ["jpg", "jpeg", "png", "heic"]
        case .video: return ["mp4", "mov"]
        case .audio: return ["m4a", "wav", "aac"]
        }
    }
}
