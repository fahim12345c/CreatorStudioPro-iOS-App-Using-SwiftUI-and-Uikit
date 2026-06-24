import Foundation
import os.log

enum Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.creatorstudio.app"

    enum Category: String {
        case camera = "Camera"
        case audio = "Audio"
        case speech = "Speech"
        case vision = "Vision"
        case service = "Service"
        case ui = "UI"
        case permission = "Permission"
        case general = "General"
    }

    static func debug(_ message: String, category: Category = .general, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let log = OSLog(subsystem: subsystem, category: category.rawValue)
        os_log(.debug, log: log, "[%@:%d] %@", fileName, line, message)
    }

    static func info(_ message: String, category: Category = .general) {
        let log = OSLog(subsystem: subsystem, category: category.rawValue)
        os_log(.info, log: log, "%@", message)
    }

    static func error(_ message: String, category: Category = .general, error: Error? = nil) {
        let log = OSLog(subsystem: subsystem, category: category.rawValue)
        let errorMessage = error.map { "\(message): \($0.localizedDescription)" } ?? message
        os_log(.error, log: log, "%@", errorMessage)
    }

    static func fault(_ message: String, category: Category = .general) {
        let log = OSLog(subsystem: subsystem, category: category.rawValue)
        os_log(.fault, log: log, "%@", message)
    }
}
