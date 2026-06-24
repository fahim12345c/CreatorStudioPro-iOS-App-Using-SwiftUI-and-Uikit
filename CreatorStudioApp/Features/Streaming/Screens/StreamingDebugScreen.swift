import SwiftUI

struct StreamingDebugScreen: View {
    @StateObject private var viewModel = StreamingViewModel()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Stream URL (e.g. localhost:8080)", text: $viewModel.streamURL)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal)

            Button(action: {
                viewModel.isStreaming ? viewModel.stopStreaming() : viewModel.startStreaming()
            }) {
                Label(
                    viewModel.isStreaming ? "Stop Streaming" : "Start Streaming",
                    systemImage: viewModel.isStreaming ? "stop.fill" : "antenna.radiowaves.left.and.right"
                )
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(viewModel.isStreaming ? Color.red : Color.green)
                .cornerRadius(AppConstants.UI.cornerRadius)
            }
            .disabled(viewModel.streamURL.isEmpty)

            if viewModel.isStreaming {
                StreamStatisticsView(statistics: viewModel.statistics)
                    .padding()

                NetworkStatusView(isConnected: viewModel.isConnected)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top)
        .navigationTitle("Streaming Debug")
    }
}
