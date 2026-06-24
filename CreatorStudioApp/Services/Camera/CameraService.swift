import Combine
import AVFoundation
import UIKit

protocol CameraServiceDelegate: AnyObject {
    func cameraService(_ service: CameraService, didOutput sampleBuffer: CMSampleBuffer)
    func cameraServiceDidStartSession(_ service: CameraService)
    func cameraServiceDidStopSession(_ service: CameraService)
    func cameraService(_ service: CameraService, didFailWith error: Error)
}

final class CameraService: NSObject, ObservableObject {
    static let isAvailable: Bool = {
        AVCaptureDevice.bestCamera(for: .back) != nil || AVCaptureDevice.bestCamera(for: .front) != nil
    }()

    let session = AVCaptureSession()
    weak var delegate: CameraServiceDelegate?

    @Published var isRunning = false
    @Published var cameraPosition: AVCaptureDevice.Position = .back
    @Published var zoomFactor: CGFloat = 1.0
    @Published var isTorchOn = false
    @Published var isConfigured = false
    @Published var videoSize: CGSize = .zero

    private let sessionQueue = DispatchQueue(label: "com.creatorstudio.camera.session", qos: .userInitiated)
    private let videoOutput = AVCaptureVideoDataOutput()
    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    private let permissionManager = CameraPermissionManager.shared
    private var hasAttemptedConfig = false

    func configureSession() async -> Bool {
        guard CameraService.isAvailable else { return false }
        if hasAttemptedConfig { return isConfigured }
        hasAttemptedConfig = true

        return await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self else {
                    continuation.resume(returning: false)
                    return
                }

                self.session.beginConfiguration()
                self.session.sessionPreset = .high

                guard let camera = AVCaptureDevice.bestCamera(for: self.cameraPosition),
                      let input = try? AVCaptureDeviceInput(device: camera),
                      self.session.canAddInput(input) else {
                    self.session.commitConfiguration()
                    continuation.resume(returning: false)
                    return
                }

                self.session.addInput(input)
                self.videoInput = input

                self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
                self.videoOutput.alwaysDiscardsLateVideoFrames = true

                guard self.session.canAddOutput(self.videoOutput) else {
                    self.session.commitConfiguration()
                    continuation.resume(returning: false)
                    return
                }
                self.session.addOutput(self.videoOutput)

                if let audioDevice = AVCaptureDevice.bestAudioDevice(),
                   let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
                   self.session.canAddInput(audioInput) {
                    self.session.addInput(audioInput)
                    self.audioInput = audioInput
                }

                self.session.commitConfiguration()

                if let connection = self.videoOutput.connection(with: .video),
                   let format = connection.inputPorts.first?.formatDescription {
                    let dims = CMVideoFormatDescriptionGetDimensions(format)
                    DispatchQueue.main.async {
                        self.videoSize = CGSize(width: CGFloat(dims.width), height: CGFloat(dims.height))
                    }
                }

                DispatchQueue.main.async {
                    self.isConfigured = true
                    continuation.resume(returning: true)
                }
            }
        }
    }

    func startSession() async {
        guard CameraService.isAvailable else {
            delegate?.cameraService(self, didFailWith: CameraError.sessionNotConfigured)
            return
        }
        guard permissionManager.isAuthorized else {
            delegate?.cameraService(self, didFailWith: CameraError.permissionDenied)
            return
        }

        if !isConfigured {
            guard await configureSession() else {
                delegate?.cameraService(self, didFailWith: CameraError.sessionNotConfigured)
                return
            }
        }

        sessionQueue.async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isRunning = true
                if let self { self.delegate?.cameraServiceDidStartSession(self) }
            }
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async {
                self?.isRunning = false
                if let self { self.delegate?.cameraServiceDidStopSession(self) }
            }
        }
    }

    func switchCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            let newPosition: AVCaptureDevice.Position = self.cameraPosition == .back ? .front : .back
            self.session.beginConfiguration()
            if let currentInput = self.videoInput { self.session.removeInput(currentInput) }
            guard let camera = AVCaptureDevice.bestCamera(for: newPosition),
                  let newInput = try? AVCaptureDeviceInput(device: camera),
                  self.session.canAddInput(newInput) else {
                self.session.commitConfiguration()
                return
            }
            self.session.addInput(newInput)
            self.videoInput = newInput
            self.session.commitConfiguration()
            DispatchQueue.main.async { self.cameraPosition = newPosition }
        }
    }

    func setZoom(_ factor: CGFloat) {
        guard let device = videoInput?.device else { return }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            device.unlockForConfiguration()
            DispatchQueue.main.async { self.zoomFactor = device.videoZoomFactor }
        } catch {
            Logger.error("Failed to set zoom", category: .camera)
        }
    }

    func toggleTorch() {
        guard let device = videoInput?.device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = isTorchOn ? .off : .on
            device.unlockForConfiguration()
            DispatchQueue.main.async { self.isTorchOn.toggle() }
        } catch {
            Logger.error("Failed to toggle torch", category: .camera)
        }
    }

    func focus(at point: CGPoint) {
        guard let device = videoInput?.device, device.isFocusModeSupported(.autoFocus) else { return }
        do {
            try device.lockForConfiguration()
            device.focusPointOfInterest = point
            device.focusMode = .autoFocus
            device.unlockForConfiguration()
        } catch {
            Logger.error("Failed to focus", category: .camera)
        }
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.cameraService(self, didOutput: sampleBuffer)
    }
}
