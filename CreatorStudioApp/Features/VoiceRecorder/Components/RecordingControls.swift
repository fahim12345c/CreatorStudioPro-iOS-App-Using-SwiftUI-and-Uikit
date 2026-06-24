import SwiftUI

struct RecordingControls: View {
    let isRecording: Bool
    let onStart: () -> Void
    let onStop: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            if isRecording {
                Button(action: onStop) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.red)
                }
            } else {
                Button(action: onStart) {
                    Image(systemName: "record.circle")
                        .font(.system(size: 64))
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
    }
}
