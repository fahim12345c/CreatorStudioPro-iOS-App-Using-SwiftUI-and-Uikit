import SwiftUI

struct ExportButton: View {
    let isExporting: Bool
    let progress: Float
    let onExport: () -> Void

    var body: some View {
        Button(action: onExport) {
            HStack(spacing: 8) {
                if isExporting {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                    Text("\(Int(progress * 100))%")
                } else {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(isExporting)
    }
}
