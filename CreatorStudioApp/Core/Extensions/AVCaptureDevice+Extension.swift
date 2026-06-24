import AVFoundation

extension AVCaptureDevice {
    static func bestCamera(for position: AVCaptureDevice.Position = .back) -> AVCaptureDevice? {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualCamera,
            .builtInWideAngleCamera
        ]

        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: position
        )

        return discoverySession.devices.first
    }

    static func bestAudioDevice() -> AVCaptureDevice? {
        AVCaptureDevice.default(for: .audio)
    }

    var supportedFrameRateRanges: [AVFrameRateRange] {
        activeFormat.videoSupportedFrameRateRanges
    }

    func configureForHighestFrameRate() {
        guard let range = supportedFrameRateRanges.last else { return }
        do {
            try lockForConfiguration()
            activeVideoMinFrameDuration = range.minFrameDuration
            activeVideoMaxFrameDuration = range.minFrameDuration
            unlockForConfiguration()
        } catch {
            print("Failed to configure frame rate: \(error)")
        }
    }
}
