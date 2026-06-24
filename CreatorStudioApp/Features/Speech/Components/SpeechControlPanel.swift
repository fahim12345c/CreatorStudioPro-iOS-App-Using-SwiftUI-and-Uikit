import SwiftUI

struct SpeechControlPanel: View {
    let isRecognizing: Bool
    let onToggleRecognition: () -> Void

    var body: some View {
        HStack(spacing: 30) {
            Button(action: onToggleRecognition) {
                VStack(spacing: 8) {
                    Image(systemName: isRecognizing ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(isRecognizing ? .red : .appPrimary)
                    Text(isRecognizing ? "Stop" : "Start")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
    }
}
