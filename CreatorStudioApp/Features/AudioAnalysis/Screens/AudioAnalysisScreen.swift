import SwiftUI

struct AudioAnalysisScreen: View {
    @StateObject private var viewModel = AudioAnalysisViewModel()

    var body: some View {
        VStack(spacing: 20) {
            WaveformView(samples: viewModel.waveform)
                .frame(height: 200)
                .padding()

            AudioMeterView(
                averagePower: viewModel.averagePower,
                peakPower: viewModel.peakPower,
                isSilent: viewModel.isSilent
            )
            .padding(.horizontal)

            HStack(spacing: 30) {
                MetricView(label: "Frequency", value: String(format: "%.1f Hz", viewModel.frequency))
                MetricView(label: "Amplitude", value: String(format: "%.3f", viewModel.amplitude))
            }
            .padding(.horizontal)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            Button(action: {
                viewModel.isAnalyzing ? viewModel.stopAnalysis() : viewModel.startAnalysis()
            }) {
                HStack {
                    Image(systemName: viewModel.isAnalyzing ? "stop.fill" : "play.fill")
                    Text(viewModel.isAnalyzing ? "Stop Analysis" : "Start Analysis")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(viewModel.isAnalyzing ? Color.red : Color.appPrimary)
                .cornerRadius(AppConstants.UI.cornerRadius)
            }

            Spacer()
        }
        .navigationTitle("Audio Analysis")
    }
}

struct MetricView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label).font(.caption).foregroundColor(.appSecondaryText)
            Text(value).font(.title3.monospacedDigit()).fontWeight(.semibold)
        }
        .padding()
        .background(Color.appSecondaryBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
    }
}
