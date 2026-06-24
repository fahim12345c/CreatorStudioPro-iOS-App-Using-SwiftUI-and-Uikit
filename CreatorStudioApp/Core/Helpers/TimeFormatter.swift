import Foundation

enum TimeFormatter {
    static func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    static func formatTimeWithMilliseconds(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        let milliseconds = Int(interval.truncatingRemainder(dividingBy: 1) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }

    static func formatDate(_ date: Date, format: String = "MMM d, yyyy 'at' h:mm a") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    static func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    static func formatFileSize(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
