import SwiftUI

struct TranscriptView: View {
    let text: String
    let isActive: Bool

    var body: some View {
        ScrollView {
            Text(text.isEmpty ? "Tap the microphone to start transcribing..." : text)
                .font(.body)
                .foregroundColor(text.isEmpty ? .appSecondaryText : .appText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Color.appSecondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal)
        .overlay(alignment: .topTrailing) {
            if isActive {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("Listening")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .padding(8)
            }
        }
    }
}
