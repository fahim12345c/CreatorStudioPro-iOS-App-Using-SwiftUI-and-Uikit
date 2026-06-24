import SwiftUI

struct LiveTranscriptView: View {
    let text: String

    var body: some View {
        ScrollView {
            Text(text.isEmpty ? "Waiting for speech..." : text)
                .font(.body)
                .foregroundColor(text.isEmpty ? .appSecondaryText : .appText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Color.appSecondaryBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
    }
}
