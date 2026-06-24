import SwiftUI

struct CaptureButton: View {
    let action: () -> Void
    let isRecording: Bool
    let isVideoMode: Bool

    init(action: @escaping () -> Void, isRecording: Bool, isVideoMode: Bool = false) {
        self.action = action
        self.isRecording = isRecording
        self.isVideoMode = isVideoMode
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                if isRecording {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red)
                        .frame(width: 28, height: 28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.red, lineWidth: 4)
                                .frame(width: 70, height: 70)
                        )
                } else {
                    Circle()
                        .fill(isVideoMode ? Color.red : Color.white)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(isVideoMode ? Color.red : Color.white, lineWidth: 4)
                                .frame(width: 70, height: 70)
                        )
                }
            }
        }
    }
}
