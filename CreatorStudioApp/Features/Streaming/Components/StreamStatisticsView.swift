import SwiftUI

struct StreamStatisticsView: View {
    let statistics: StreamStatistics

    var body: some View {
        VStack(spacing: 12) {
            StatRow(label: "Status", value: statistics.isStreaming ? "Streaming" : "Idle")
            StatRow(label: "FPS", value: String(format: "%.1f", statistics.fps))
            StatRow(label: "Bitrate", value: String(format: "%.0f kbps", statistics.bitrate / 1000))
            StatRow(label: "Total Frames", value: "\(statistics.totalFrames)")
            StatRow(label: "Dropped Frames", value: "\(statistics.droppedFrames)")
            StatRow(label: "Frame Drop Rate", value: String(format: "%.1f%%", statistics.frameDropRate))
            StatRow(label: "Uptime", value: TimeFormatter.formatTimeInterval(statistics.uptime))
            StatRow(label: "Latency", value: String(format: "%.0f ms", statistics.networkLatency * 1000))
        }
        .padding()
        .background(Color.appSecondaryBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.appSecondaryText)
            Spacer()
            Text(value)
                .font(.subheadline.monospacedDigit())
                .fontWeight(.medium)
        }
    }
}
