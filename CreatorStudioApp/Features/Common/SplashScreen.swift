import SwiftUI

struct SplashScreen: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var showLoading = false
    @State private var loadingDots = 0

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.498, blue: 1.0),
                    Color(red: 0.4, green: 0.65, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "camera.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    .scaleEffect(scale)
                    .opacity(opacity)

                Text("CreatorStudio")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(opacity)

                Text("Camera • Audio • Vision • Stream")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(opacity)

                Spacer()

                if showLoading {
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(.white)
                                .frame(width: 8, height: 8)
                                .scaleEffect(loadingDots == index ? 1.3 : 0.7)
                                .opacity(loadingDots == index ? 1.0 : 0.5)
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        withAnimation(.easeOut(duration: 0.8)) {
            opacity = 1.0
            scale = 1.0
        }

        withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
            showLoading = true
        }

        let timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                loadingDots = (loadingDots + 1) % 3
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            timer.invalidate()
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onComplete()
            }
        }
    }
}

#Preview {
    SplashScreen {}
}
