import UIKit
import AVFoundation

final class PlayerContainerView: UIView {
    private let playerService: VideoPlayerService
    private var playerLayer: AVPlayerLayer?

    init(playerService: VideoPlayerService, frame: CGRect = .zero) {
        self.playerService = playerService
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let layer = AVPlayerLayer(player: playerService.player)
        layer.videoGravity = .resizeAspect
        layer.frame = bounds
        self.layer.addSublayer(layer)
        playerLayer = layer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
