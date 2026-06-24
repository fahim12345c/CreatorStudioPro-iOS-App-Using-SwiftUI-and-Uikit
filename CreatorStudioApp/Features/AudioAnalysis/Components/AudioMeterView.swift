import SwiftUI

struct AudioMeterView: View {
    let averagePower: Float
    let peakPower: Float
    let isSilent: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Level")
                    .font(.caption)
                    .foregroundColor(.appSecondaryText)
                Spacer()
                Text(isSilent ? "Silent" : "Active")
                    .font(.caption)
                    .foregroundColor(isSilent ? .gray : .green)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appSecondaryBackground)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(meterColor)
                        .frame(width: geo.size.width * CGFloat(normalizedLevel))
                }
            }
            .frame(height: 20)

            HStack {
                Text("Avg: \(Int(averagePower)) dB")
                    .font(.caption2)
                    .foregroundColor(.appSecondaryText)
                Spacer()
                Text("Peak: \(Int(peakPower)) dB")
                    .font(.caption2)
                    .foregroundColor(.appSecondaryText)
            }
        }
    }

    private var normalizedLevel: Float {
        let power = max(-60, min(0, averagePower))
        return (power + 60) / 60
    }

    private var meterColor: Color {
        switch normalizedLevel {
        case 0..<0.3: return .green
        case 0.3..<0.6: return .yellow
        default: return .red
        }
    }
}
