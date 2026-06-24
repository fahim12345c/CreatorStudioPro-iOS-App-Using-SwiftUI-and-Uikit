import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var selectedTab: AppRouter.Tab = .home
    @Published var navigationPath = NavigationPath()
    @Published var activeSheet: AppRouter.Sheet?
    @Published var showPermissions = false
    @Published var permissionsGranted = false

    private lazy var _cameraViewModel = CameraViewModel()
    private lazy var _speechViewModel = SpeechViewModel()
    private lazy var _voiceMemoViewModel = VoiceMemoViewModel()
    private lazy var _mediaPlayerViewModel = MediaPlayerViewModel()
    private lazy var _faceDetectionViewModel: FaceDetectionViewModel = {
        let vm = FaceDetectionViewModel()
        return vm
    }()
    private lazy var _audioAnalysisViewModel = AudioAnalysisViewModel()
    private lazy var _streamingViewModel = StreamingViewModel()
    private lazy var _multiCamViewModel = MultiCamViewModel()

    var cameraViewModel: CameraViewModel { _cameraViewModel }
    var speechViewModel: SpeechViewModel { _speechViewModel }
    var voiceMemoViewModel: VoiceMemoViewModel { _voiceMemoViewModel }
    var mediaPlayerViewModel: MediaPlayerViewModel { _mediaPlayerViewModel }
    var faceDetectionViewModel: FaceDetectionViewModel { _faceDetectionViewModel }
    var audioAnalysisViewModel: AudioAnalysisViewModel { _audioAnalysisViewModel }
    var streamingViewModel: StreamingViewModel { _streamingViewModel }
    var multiCamViewModel: MultiCamViewModel { _multiCamViewModel }

    func checkPermissions() {
        let state = PermissionCoordinator.shared.currentState
        if state.camera == .notDetermined || state.microphone == .notDetermined {
            showPermissions = true
        }
    }

    func requestPermissions() async {
        let granted = await PermissionCoordinator.shared.requestAllPermissions()
        permissionsGranted = granted
        showPermissions = !granted
    }

    func navigate(to destination: AppRouter.Destination) {
        navigationPath.append(destination)
    }

    func presentSheet(_ sheet: AppRouter.Sheet) {
        activeSheet = sheet
    }

    func dismissSheet() {
        activeSheet = nil
    }

    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
