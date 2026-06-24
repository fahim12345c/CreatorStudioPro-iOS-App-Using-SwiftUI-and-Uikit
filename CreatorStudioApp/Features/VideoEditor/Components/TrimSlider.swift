import SwiftUI

struct TrimSliderControl: View {
    let position: CGFloat
    let onDrag: (CGFloat) -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .frame(width: 20)
                .shadow(radius: 2)
        }
        .frame(width: 20)
        .gesture(
            DragGesture()
                .onChanged { value in
                    onDrag(value.location.x)
                }
        )
    }
}
