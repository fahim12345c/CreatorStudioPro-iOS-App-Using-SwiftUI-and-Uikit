import SwiftUI

struct ScannerScreen: View {
    @StateObject private var viewModel = ScannerViewModel()
    @State private var showCopied = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.cameraUnavailable {
                VStack(spacing: 16) {
                    Image(systemName: "camera.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.appSecondaryText)
                    Text("Camera Unavailable")
                        .font(.headline)
                    Text("Camera hardware is not available on this device.")
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                CameraPreview(cameraService: viewModel.cameraService)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    ScannerViewfinder()
                        .frame(width: 250, height: 250)
                        .padding(.bottom, 40)

                    if let code = viewModel.lastScannedCode {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Detected")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(code.type.uppercased())
                                    .font(.caption)
                                    .foregroundColor(.appSecondaryText)
                                Text(code.value)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .textSelection(.enabled)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(12)

                            HStack(spacing: 12) {
                                Button {
                                    UIPasteboard.general.string = code.value
                                    showCopied = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showCopied = false
                                    }
                                } label: {
                                    Label(showCopied ? "Copied!" : "Copy", systemImage: "doc.on.doc")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(.appPrimary)

                                if let url = URL(string: code.value),
                                   url.scheme != nil,
                                   UIApplication.shared.canOpenURL(url) {
                                    Button {
                                        UIApplication.shared.open(url)
                                    } label: {
                                        Label("Open", systemImage: "safari")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.green)
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    } else {
                        Text("Point camera at a QR code or barcode")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(.black.opacity(0.6))
                            .cornerRadius(12)
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationTitle("Scanner")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }
}

struct ScannerViewfinder: View {
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let lineWidth: CGFloat = 4
            let cornerLength: CGFloat = 30

            Path { path in
                path.move(to: CGPoint(x: 0, y: cornerLength))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: cornerLength, y: 0))

                path.move(to: CGPoint(x: size.width - cornerLength, y: 0))
                path.addLine(to: CGPoint(x: size.width, y: 0))
                path.addLine(to: CGPoint(x: size.width, y: cornerLength))

                path.move(to: CGPoint(x: size.width, y: size.height - cornerLength))
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.addLine(to: CGPoint(x: size.width - cornerLength, y: size.height))

                path.move(to: CGPoint(x: cornerLength, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: size.height - cornerLength))
            }
            .stroke(Color.appPrimary, lineWidth: lineWidth)
        }
    }
}

@MainActor
final class ScannerViewModel: ObservableObject {
    let cameraService = CameraService()
    @Published var lastScannedCode: ScannerService.ScannedCode?
    @Published var cameraUnavailable = false

    private let scannerService = ScannerService()

    init() {
        scannerService.delegate = self
    }

    func start() {
        guard CameraService.isAvailable else {
            cameraUnavailable = true
            return
        }
        Task {
            let granted = await PermissionCoordinator.shared.requestCameraAndMicrophone()
            if granted {
                let configured = await cameraService.configureSession()
                if configured {
                    scannerService.configure(with: cameraService.session)
                    scannerService.startScanning()
                    await cameraService.startSession()
                }
            }
        }
    }

    func stop() {
        scannerService.stopScanning()
        cameraService.stopSession()
    }
}

extension ScannerViewModel: ScannerServiceDelegate {
    func scannerService(_ service: ScannerService, didDetect code: ScannerService.ScannedCode) {
        lastScannedCode = code
    }
}
