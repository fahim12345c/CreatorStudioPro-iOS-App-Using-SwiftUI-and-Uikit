import SwiftUI

struct CameraControlsView: View {
    @Binding var currentMode: CameraViewModel.CameraMode
    let isRecording: Bool
    let isPaused: Bool
    let onCapture: () -> Void
    let onToggleRecording: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let recordingDuration: TimeInterval
    let canRecord: Bool

    init(
        currentMode: Binding<CameraViewModel.CameraMode>,
        isRecording: Bool,
        isPaused: Bool = false,
        onCapture: @escaping () -> Void,
        onToggleRecording: @escaping () -> Void,
        onPause: @escaping () -> Void = {},
        onResume: @escaping () -> Void = {},
        recordingDuration: TimeInterval,
        canRecord: Bool = true
    ) {
        _currentMode = currentMode
        self.isRecording = isRecording
        self.isPaused = isPaused
        self.onCapture = onCapture
        self.onToggleRecording = onToggleRecording
        self.onPause = onPause
        self.onResume = onResume
        self.recordingDuration = recordingDuration
        self.canRecord = canRecord
    }

    var body: some View {
        VStack(spacing: 20) {
            if currentMode == .video {
                HStack(spacing: 16) {
                    if isRecording {
                        RecordingTimerView(duration: recordingDuration)

                        if isPaused {
                            Button(action: onResume) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                            }
                        } else {
                            Button(action: onPause) {
                                Image(systemName: "pause.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }

            HStack(spacing: 40) {
                Button(action: { currentMode = .photo }) {
                    Image(systemName: "camera")
                        .font(.title2)
                        .foregroundColor(currentMode == .photo ? .yellow : .white)
                }

                CaptureButton(
                    action: currentMode == .photo ? onCapture : onToggleRecording,
                    isRecording: isRecording,
                    isVideoMode: currentMode == .video
                )
                .opacity(canRecord ? 1 : 0.4)
                .disabled(!canRecord)
                .scaleEffect(currentMode == .video && !isRecording ? 1.1 : 1.0)

                Button(action: { currentMode = .video }) {
                    Image(systemName: "video")
                        .font(.title2)
                        .foregroundColor(currentMode == .video ? .yellow : .white)
                }
            }
        }
        .padding(.bottom, 40)
    }
}
