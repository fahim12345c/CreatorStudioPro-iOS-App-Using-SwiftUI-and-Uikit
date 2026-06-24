import SwiftUI
import AVFoundation

struct PlayerPreview: UIViewControllerRepresentable {
    let playerService: VideoPlayerService

    func makeUIViewController(context: Context) -> PlayerViewController {
        PlayerViewController(playerService: playerService)
    }

    func updateUIViewController(_ uiViewController: PlayerViewController, context: Context) {}
}
