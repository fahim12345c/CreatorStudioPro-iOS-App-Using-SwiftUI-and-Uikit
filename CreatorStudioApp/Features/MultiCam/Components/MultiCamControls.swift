import SwiftUI

struct MultiCamControls: View {
    let isRunning: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            Label(
                isRunning ? "Stop Multi-Cam" : "Start Multi-Cam",
                systemImage: isRunning ? "stop.fill" : "play.fill"
            )
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(isRunning ? Color.red : Color.green)
            .cornerRadius(AppConstants.UI.cornerRadius)
        }
    }
}
