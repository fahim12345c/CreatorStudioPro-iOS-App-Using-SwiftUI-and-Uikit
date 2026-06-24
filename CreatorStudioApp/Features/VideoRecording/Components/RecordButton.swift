import SwiftUI

struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(isRecording ? Color.red : Color.white, lineWidth: 4)
                    .frame(width: 70, height: 70)

                if isRecording {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red)
                        .frame(width: 24, height: 24)
                } else {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 56, height: 56)
                }
            }
        }
    }
}
