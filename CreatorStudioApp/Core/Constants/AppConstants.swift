import Foundation

enum AppConstants {
    static let appName = "CreatorStudioPro"
    static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersionString"] as? String ?? "1"

    enum Video {
        static let defaultFPS: Int32 = 30
        static let highFPS: Int32 = 60
        static let maxDuration: TimeInterval = 600
        static let recommendedBitrate: Float = 8_000_000
    }

    enum Audio {
        static let sampleRate: Double = 44100
        static let numberOfChannels: Int = 2
        static let bitRate: Int = 128_000
    }

    enum UI {
        static let cornerRadius: CGFloat = 12
        static let buttonSize: CGFloat = 44
        static let recordButtonSize: CGFloat = 80
        static let spacing: CGFloat = 16
        static let animationDuration: TimeInterval = 0.3
    }
}
