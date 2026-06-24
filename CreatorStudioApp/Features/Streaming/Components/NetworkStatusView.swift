import SwiftUI

struct NetworkStatusView: View {
    let isConnected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 10, height: 10)
            Text(isConnected ? "Connected" : "Disconnected")
                .font(.subheadline)
                .foregroundColor(isConnected ? .green : .red)
            Spacer()
            if !isConnected {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding()
        .background(Color.appSecondaryBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
    }
}
