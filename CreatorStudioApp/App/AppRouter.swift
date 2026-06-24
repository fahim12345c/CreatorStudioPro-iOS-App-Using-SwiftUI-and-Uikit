import SwiftUI

enum AppRouter {
    enum Tab: String, CaseIterable, Identifiable {
        case camera = "camera"
        case media = "media"
        case speech = "speech"
        case vision = "vision"
        case tools = "tools"

        var id: String { rawValue }

        var title: String {
            switch self {
            case .camera: return "Camera"
            case .media: return "Media"
            case .speech: return "Speech"
            case .vision: return "Vision"
            case .tools: return "Tools"
            }
        }

        var icon: String {
            switch self {
            case .camera: return "camera.fill"
            case .media: return "photo.on.rectangle"
            case .speech: return "waveform"
            case .vision: return "faceid"
            case .tools: return "wrench.and.screwdriver"
            }
        }

        @ViewBuilder
        var destination: some View {
            switch self {
            case .camera:
                CameraScreen()
            case .media:
                MediaLibraryScreen()
            case .speech:
                TranscriptScreen()
            case .vision:
                FaceDetectionScreen()
            case .tools:
                ToolsMenuView()
            }
        }
    }

    enum Destination: Hashable {
        case videoPlayer(video: VideoModel)
        case audioPlayer(audio: AudioRecordingModel)
        case videoEditor(url: URL)
        case faceTracking
        case audioAnalysis
        case ttsPlayground
        case scanner
        case streamingDebug
        case videoRecorder
        case voiceRecorder
        case ocr
        case gallery
        case videoLibrary
        case photoViewer(url: URL)

        @ViewBuilder
        var view: some View {
            switch self {
            case .videoPlayer(let video):
                VideoPlayerScreen(video: video)
            case .audioPlayer(let audio):
                AudioPlayerScreen(audio: audio)
            case .videoEditor(let url):
                VideoEditorScreen(videoURL: url)
            case .faceTracking:
                FaceTrackingScreen()
            case .audioAnalysis:
                AudioAnalysisScreen()
            case .ttsPlayground:
                TTSPlaygroundScreen()
            case .scanner:
                ScannerScreen()
            case .streamingDebug:
                StreamingDebugScreen()
            case .videoRecorder:
                VideoRecorderScreen()
            case .voiceRecorder:
                VoiceMemoScreen()
            case .ocr:
                OCRScreen()
            case .gallery:
                GalleryScreen()
            case .videoLibrary:
                VideoLibraryScreen()
            case .photoViewer(let url):
                PhotoViewerScreen(url: url)
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
            case .videoPlayer(let video):
                hasher.combine("videoPlayer")
                hasher.combine(video.id)
            case .audioPlayer(let audio):
                hasher.combine("audioPlayer")
                hasher.combine(audio.id)
            case .videoEditor(let url):
                hasher.combine("videoEditor")
                hasher.combine(url)
            case .faceTracking:
                hasher.combine("faceTracking")
            case .audioAnalysis:
                hasher.combine("audioAnalysis")
            case .ttsPlayground:
                hasher.combine("ttsPlayground")
            case .scanner:
                hasher.combine("scanner")
            case .streamingDebug:
                hasher.combine("streamingDebug")
            case .videoRecorder:
                hasher.combine("videoRecorder")
            case .voiceRecorder:
                hasher.combine("voiceRecorder")
            case .ocr:
                hasher.combine("ocr")
            case .gallery:
                hasher.combine("gallery")
            case .videoLibrary:
                hasher.combine("videoLibrary")
            case .photoViewer(let url):
                hasher.combine("photoViewer")
                hasher.combine(url)
            }
        }

        static func == (lhs: Destination, rhs: Destination) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
    }

    enum Sheet: Identifiable {
        case settings
        case gallery
        case export

        var id: String {
            switch self {
            case .settings: return "settings"
            case .gallery: return "gallery"
            case .export: return "export"
            }
        }

        @ViewBuilder
        var view: some View {
            switch self {
            case .settings:
                SettingsView()
            case .gallery:
                GalleryScreen()
            case .export:
                EmptyView()
            }
        }
    }
}

struct ToolsMenuView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        List {
            Section("Recording") {
                NavigationLink(value: AppRouter.Destination.voiceRecorder) {
                    Label("Voice Recorder", systemImage: "mic")
                }
            }

            Section("Analysis") {
                NavigationLink(value: AppRouter.Destination.audioAnalysis) {
                    Label("Audio Analysis", systemImage: "waveform.and.magnifyingglass")
                }
            }

            Section("Creative") {
                NavigationLink(value: AppRouter.Destination.ttsPlayground) {
                    Label("Text to Speech", systemImage: "speaker.wave.2")
                }
            }

            Section("Utilities") {
                NavigationLink(value: AppRouter.Destination.ocr) {
                    Label("OCR - Text Recognition", systemImage: "text.viewfinder")
                }
                NavigationLink(value: AppRouter.Destination.scanner) {
                    Label("QR & Barcode Scanner", systemImage: "qrcode.viewfinder")
                }
            }

            Section("Advanced") {
                NavigationLink(value: AppRouter.Destination.streamingDebug) {
                    Label("Streaming Debug", systemImage: "antenna.radiowaves.left.and.right")
                }
            }
        }
        .navigationTitle("Tools")
    }
}

struct SettingsView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Permissions") {
                    HStack {
                        Text("Camera")
                        Spacer()
                        PermissionBadge(status: PermissionCoordinator.shared.currentState.camera)
                    }
                    HStack {
                        Text("Microphone")
                        Spacer()
                        PermissionBadge(status: PermissionCoordinator.shared.currentState.microphone)
                    }
                    HStack {
                        Text("Speech")
                        Spacer()
                        PermissionBadge(status: PermissionCoordinator.shared.currentState.speech)
                    }
                }

                Section("Storage") {
                    HStack {
                        Text("Used")
                        Spacer()
                        Text(TimeFormatter.formatFileSize(StorageManager.shared.totalStorageUsed))
                            .foregroundColor(.appSecondaryText)
                    }
                    Button("Clear All Data", role: .destructive) {
                        StorageManager.shared.clearAllData()
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(AppConstants.version)
                            .foregroundColor(.appSecondaryText)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct PermissionBadge: View {
    let status: PermissionStatus

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.caption)
                .foregroundColor(color)
        }
    }

    private var color: Color {
        switch status {
        case .authorized: return .green
        case .denied, .restricted: return .red
        case .notDetermined: return .gray
        }
    }

    private var text: String {
        switch status {
        case .authorized: return "Granted"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Unknown"
        }
    }
}
