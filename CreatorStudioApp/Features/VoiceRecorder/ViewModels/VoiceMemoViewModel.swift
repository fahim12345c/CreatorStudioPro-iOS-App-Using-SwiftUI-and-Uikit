import SwiftUI
import Combine

@MainActor
final class VoiceMemoViewModel: ObservableObject {
    let recorderService = AudioRecorderService()
    let playerService = AudioPlayerService()

    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var averagePower: Float = 0
    @Published var recordings: [AudioRecordingModel] = []
    @Published var selectedRecording: AudioRecordingModel?
    @Published var permissionDenied = false

    init() {
        recorderService.delegate = self
        playerService.delegate = self
        loadRecordings()
    }

    func startRecording() {
        Task {
            let granted = await PermissionCoordinator.shared.requestCameraAndMicrophone()
            if granted {
                recorderService.startRecording()
                permissionDenied = false
            } else {
                permissionDenied = true
            }
        }
    }

    func stopRecording() {
        recorderService.stopRecording()
    }

    func playRecording(_ recording: AudioRecordingModel) {
        if isPlaying && selectedRecording?.id == recording.id {
            stopPlayback()
            return
        }
        selectedRecording = recording
        playerService.load(recording.url)
        playerService.play()
    }

    func stopPlayback() {
        playerService.stop()
        selectedRecording = nil
    }

    func deleteRecording(_ recording: AudioRecordingModel) {
        StorageManager.shared.deleteFile(at: recording.url)
        loadRecordings()
    }

    private func loadRecordings() {
        recordings = StorageManager.shared.loadAllAudioFiles()
            .map { AudioRecordingModel(url: $0, duration: AudioHelper.duration(for: $0)) }
            .sorted { $0.creationDate > $1.creationDate }
    }
}

extension VoiceMemoViewModel: AudioRecorderServiceDelegate {
    func audioRecorderServiceDidStartRecording(_ service: AudioRecorderService) {
        isRecording = true
    }

    func audioRecorderServiceDidFinishRecording(_ service: AudioRecorderService, at url: URL) {
        isRecording = false
        loadRecordings()
    }

    func audioRecorderService(_ service: AudioRecorderService, didUpdateAveragePower power: Float) {
        averagePower = power
    }

    func audioRecorderService(_ service: AudioRecorderService, didFailWith error: Error) {
        isRecording = false
    }

    func audioRecorderServiceDidPauseRecording(_ service: AudioRecorderService) {}
    func audioRecorderServiceDidResumeRecording(_ service: AudioRecorderService) {}
}

extension VoiceMemoViewModel: AudioPlayerServiceDelegate {
    func audioPlayerServiceDidFinishPlaying(_ service: AudioPlayerService) {
        isPlaying = false
        currentTime = 0
    }

    func audioPlayerService(_ service: AudioPlayerService, didUpdateTime time: TimeInterval) {
        currentTime = time
    }

    func audioPlayerService(_ service: AudioPlayerService, didFailWith error: Error) {}
}
