import UIKit
import AVFoundation

final class PlayerViewController: UIViewController {
    private let playerService: VideoPlayerService
    private var playerLayer: AVPlayerLayer?

    init(playerService: VideoPlayerService) {
        self.playerService = playerService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerLayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }

    private func setupPlayerLayer() {
        let layer = AVPlayerLayer(player: playerService.player)
        layer.videoGravity = .resizeAspect
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        playerLayer = layer
    }
}
