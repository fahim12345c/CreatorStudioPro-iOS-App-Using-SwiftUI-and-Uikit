import SwiftUI

struct SeekBarView: View {
    @Binding var currentTime: TimeInterval
    let duration: TimeInterval
    let onSeek: (TimeInterval) -> Void

    @State private var isDragging = false
    @State private var dragValue: Double = 0

    var body: some View {
        VStack(spacing: 4) {
            Slider(
                value: Binding(
                    get: { isDragging ? dragValue : (duration > 0 ? currentTime / duration : 0) },
                    set: { newValue in
                        dragValue = newValue
                        isDragging = true
                    }
                ),
                onEditingChanged: { editing in
                    if !editing {
                        isDragging = false
                        onSeek(dragValue * duration)
                    }
                }
            )
            .tint(.appPrimary)

            HStack {
                Text(TimeFormatter.formatTimeInterval(isDragging ? dragValue * duration : currentTime))
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.appSecondaryText)
                Spacer()
                Text(TimeFormatter.formatTimeInterval(duration))
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.appSecondaryText)
            }
        }
    }
}
