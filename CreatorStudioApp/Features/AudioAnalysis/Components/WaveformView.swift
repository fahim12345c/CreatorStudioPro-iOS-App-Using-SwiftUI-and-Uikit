import SwiftUI

struct WaveformView: View {
    let samples: [Float]

    var body: some View {
        GeometryReader { geo in
            Path { path in
                let width = geo.size.width
                let height = geo.size.height
                let midY = height / 2
                let spacing = width / CGFloat(max(samples.count, 1))

                path.move(to: CGPoint(x: 0, y: midY))

                for (index, sample) in samples.enumerated() {
                    let x = CGFloat(index) * spacing
                    let amplitude = CGFloat(min(max(sample, 0), 1)) * height * 0.4
                    path.addLine(to: CGPoint(x: x, y: midY - amplitude))
                }

                for (index, sample) in samples.reversed().enumerated() {
                    let x = CGFloat(samples.count - 1 - index) * spacing
                    let amplitude = CGFloat(min(max(sample, 0), 1)) * height * 0.4
                    path.addLine(to: CGPoint(x: x, y: midY + amplitude))
                }

                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}
