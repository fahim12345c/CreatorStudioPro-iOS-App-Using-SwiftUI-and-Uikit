import SwiftUI

struct FaceStatusView: View {
    let faceCount: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "faceid")
                .font(.caption)
            Text("\(faceCount)")
                .font(.caption.bold())
        }
        .foregroundColor(faceCount > 0 ? .green : .yellow)
        .padding(6)
        .background(.black.opacity(0.6))
        .cornerRadius(8)
    }
}
