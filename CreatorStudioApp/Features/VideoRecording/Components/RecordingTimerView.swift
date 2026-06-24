import SwiftUI

struct RecordingTimerView: View {
    let duration: TimeInterval

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
            Text(TimeFormatter.formatTimeInterval(duration))
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.black.opacity(0.6))
        .cornerRadius(12)
    }
}
