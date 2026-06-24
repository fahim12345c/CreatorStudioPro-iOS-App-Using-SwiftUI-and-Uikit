import SwiftUI
import AVFoundation

@main
struct CreatorStudioApp: App {
    @StateObject private var coordinator = AppCoordinator()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreen {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
                } else {
                    RootView()
                        .environmentObject(coordinator)
                        .transition(.opacity)
                }
            }
            .onAppear {
                coordinator.checkPermissions()
                Logger.info("CreatorStudioPro launched", category: .general)
            }
        }
    }
}
