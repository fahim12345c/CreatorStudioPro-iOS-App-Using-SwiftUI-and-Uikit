import Foundation

struct StreamStatistics {
    var fps: Double = 0
    var bitrate: Double = 0
    var droppedFrames: Int = 0
    var totalFrames: Int = 0
    var audioLevel: Float = 0
    var networkLatency: TimeInterval = 0
    var isStreaming: Bool = false
    var uptime: TimeInterval = 0

    var averageBitrate: Double {
        guard uptime > 0 else { return 0 }
        return bitrate / uptime
    }

    var frameDropRate: Double {
        guard totalFrames > 0 else { return 0 }
        return Double(droppedFrames) / Double(totalFrames) * 100
    }
}
