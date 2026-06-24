import SwiftUI

struct AudioLevelView: View {
    let averagePower: Float
    let isRecording: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appSecondaryBackground)

                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [.green, .yellow, .red],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: max(0, CGFloat(normalizedPower) * geo.size.height))
                    .animation(.easeInOut(duration: 0.1), value: normalizedPower)
            }
        }
        .padding(.horizontal)
    }

    private var normalizedPower: Float {
        let power = max(-60, min(0, averagePower))
        return (power + 60) / 60
    }
}
