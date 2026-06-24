import SwiftUI

struct InterviewToolbar: View {
    let isSessionActive: Bool
    let isRecording: Bool
    let elapsedTime: TimeInterval
    let onStartSession: () -> Void
    let onStopSession: () -> Void
    let onToggleRecording: () -> Void

    var body: some View {
        HStack(spacing: 30) {
            Button(action: isSessionActive ? onStopSession : onStartSession) {
                VStack(spacing: 4) {
                    Image(systemName: isSessionActive ? "stop.circle" : "play.circle")
                        .font(.title2)
                    Text(isSessionActive ? "End" : "Start")
                        .font(.caption)
                }
            }
            .foregroundColor(isSessionActive ? .red : .green)

            if isSessionActive {
                Button(action: onToggleRecording) {
                    VStack(spacing: 4) {
                        Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                            .font(.title2)
                            .foregroundColor(isRecording ? .red : .appPrimary)
                        Text(isRecording ? "Stop Rec" : "Record")
                            .font(.caption)
                    }
                }

                Text(TimeFormatter.formatTimeInterval(elapsedTime))
                    .font(.system(.title3, design: .monospaced))
                    .foregroundColor(.appText)
            }
        }
        .padding()
        .background(Color.appSecondaryBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
    }
}
