import SwiftUI
import AVFoundation

struct TimelineView: View {
    let duration: CMTime
    let startTime: CMTime
    let endTime: CMTime
    let onUpdateStart: (Double) -> Void
    let onUpdateEnd: (Double) -> Void

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let totalDuration = CMTimeGetSeconds(duration)
            let startOffset = totalWidth * CGFloat(CMTimeGetSeconds(startTime) / max(totalDuration, 1))
            let endOffset = totalWidth * CGFloat(CMTimeGetSeconds(endTime) / max(totalDuration, 1))

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.appSecondaryBackground)

                Rectangle()
                    .fill(Color.appPrimary.opacity(0.3))
                    .frame(width: endOffset - startOffset)
                    .offset(x: startOffset)

                TrimSlider(position: startOffset, onDrag: { offset in
                    let seconds = Double(offset / totalWidth) * totalDuration
                    onUpdateStart(max(0, min(seconds, CMTimeGetSeconds(endTime) - 1)))
                })
                .offset(x: startOffset - 10)

                TrimSlider(position: endOffset, onDrag: { offset in
                    let seconds = Double(offset / totalWidth) * totalDuration
                    onUpdateEnd(max(CMTimeGetSeconds(startTime) + 1, min(seconds, totalDuration)))
                })
                .offset(x: endOffset - 10)
            }
        }
    }
}

struct TrimSlider: View {
    let position: CGFloat
    let onDrag: (CGFloat) -> Void

    var body: some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: 20)
            .gesture(DragGesture()
                .onChanged { value in
                    onDrag(value.location.x)
                }
            )
    }
}
