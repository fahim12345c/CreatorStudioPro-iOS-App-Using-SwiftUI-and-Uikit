import Combine
import AVFoundation
import UIKit

final class MultiCamService: NSObject, ObservableObject {
    @Published var isMultiCamSupported: Bool = false
    @Published var isRunning = false
    @Published var frontCameraRunning = false
    @Published var backCameraRunning = false

    let frontSession = AVCaptureMultiCamSession()
    let backSession = AVCaptureMultiCamSession()

    override private init() {
        super.init()
        isMultiCamSupported = AVCaptureMultiCamSession.isMultiCamSupported && CameraService.isAvailable
    }

    static let shared = MultiCamService()

    func startMultiCamSession() {
        guard AVCaptureMultiCamSession.isMultiCamSupported else {
            Logger.error("MultiCam not supported on this device", category: .camera)
            return
        }

        let frontCamera = AVCaptureDevice.bestCamera(for: .front)
        let backCamera = AVCaptureDevice.bestCamera(for: .back)

        guard let frontCamera, let backCamera else {
            Logger.error("Could not find both cameras", category: .camera)
            return
        }

        do {
            let frontInput = try AVCaptureDeviceInput(device: frontCamera)
            let backInput = try AVCaptureDeviceInput(device: backCamera)

            frontSession.beginConfiguration()
            frontSession.sessionPreset = .medium

            if frontSession.canAddInput(frontInput) {
                frontSession.addInput(frontInput)
            }

            let frontOutput = AVCaptureVideoDataOutput()
            frontOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.creatorstudio.multicam.front"))
            if frontSession.canAddOutput(frontOutput) {
                frontSession.addOutput(frontOutput)
            }
            frontSession.commitConfiguration()

            backSession.beginConfiguration()
            backSession.sessionPreset = .medium

            if backSession.canAddInput(backInput) {
                backSession.addInput(backInput)
            }

            let backOutput = AVCaptureVideoDataOutput()
            backOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.creatorstudio.multicam.back"))
            if backSession.canAddOutput(backOutput) {
                backSession.addOutput(backOutput)
            }
            backSession.commitConfiguration()

            frontSession.startRunning()
            backSession.startRunning()

            frontCameraRunning = true
            backCameraRunning = true
            isRunning = true
        } catch {
            Logger.error("Failed to start multi-cam session", category: .camera, error: error)
        }
    }

    func stopMultiCamSession() {
        frontSession.stopRunning()
        backSession.stopRunning()
        frontCameraRunning = false
        backCameraRunning = false
        isRunning = false
    }
}

extension MultiCamService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Forward frames for processing
    }
}
