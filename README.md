# CreatorStudioPro

**A unified media engine for camera, audio, speech, vision, editing, and streaming — built entirely in Swift.**

CreatorStudioPro is a production-grade iOS application that consolidates every major media workflow into a single, modular codebase. From real-time face detection with gender classification to live RTMP streaming, from OCR text extraction to barcode scanning — it's a complete toolkit for content creators, developers, and media professionals.

---

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Real-World Problems Solved](#real-world-problems-solved)
- [Target Users](#target-users)
- [Initial Setup](#initial-setup)
- [Architecture](#architecture)
- [Feature Workflows](#feature-workflows)
- [Project Structure](#project-structure)
- [Technical Decisions](#technical-decisions)
- [License](#license)

---

## Features

| Tab | Feature | Description |
|-----|---------|-------------|
| **Camera** | Photo Capture | High-resolution photo capture with flash, zoom, focus |
| | Video Recording | Record with pause/resume, save/discard prompt, max duration |
| | Gallery | Browse captured photos, tap to view full-screen |
| **Media** | Media Library | Grid view of all photos, videos, and audio files |
| | Video Playback | Full player with seek bar, skip forward/backward |
| | Audio Playback | Audio player with progress tracking and controls |
| | Delete Media | Long-press any item to delete with confirmation |
| **Speech** | Transcription | Real-time speech-to-text using Apple Speech framework |
| | Text-to-Speech | Synthesize text into natural-sounding audio |
| **Vision** | Face Detection | Detect faces with bounding boxes and confidence scores |
| | Gender Classification | Heuristic-based male/female detection using face landmarks |
| | Camera Switch | Toggle front/back camera during face detection |
| **Tools** | Voice Recorder | Record audio with level visualization |
| | Audio Analysis | Analyze audio files for waveform and frequency data |
| | Text-to-Speech Playground | Experiment with TTS voices and settings |
| | OCR | Extract text from images using Vision framework |
| | QR & Barcode Scanner | Scan QR codes, EAN-13, EAN-8, Code 128, UPC-E |
| | Streaming Debug | Configure and test RTMP/HLS streaming |

---

## Real-World Problems Solved

### 1. Fragmented Media Tools
**Problem:** Creators juggle 5-10 separate apps for camera, recording, editing, transcription, and streaming.

**Solution:** CreatorStudioPro unifies all media workflows into one app. Record audio, capture video, transcribe speech, detect faces, scan barcodes — all without leaving the app.

### 2. Content Creation & Moderation
**Problem:** Platforms need to moderate user-generated content for appropriate face detection, age estimation, and text extraction.

**Solution:** Real-time face detection with gender classification, plus OCR for extracting text from screenshots and documents. Useful for content review pipelines.

### 3. Accessibility Barriers
**Problem:** Visually impaired users struggle with text in images and physical products.

**Solution:** OCR extracts text from any image. Barcode/QR scanner identifies products and opens URLs. Text-to-Speech reads content aloud.

### 4. Live Streaming Complexity
**Problem:** Setting up a live stream requires understanding RTMP URLs, stream keys, encoding settings, and network configuration.

**Solution:** Built-in streaming debug tool with dynamic URL/host/port configuration, real-time statistics, and network status monitoring.

### 5. Media Asset Management
**Problem:** Scattered photos, videos, and recordings across multiple apps with no unified library.

**Solution:** Centralized media library with grid browsing, preview, playback, and delete functionality across all media types.

### 6. Speech-to-Text for Documentation
**Problem:** Manual transcription of meetings, interviews, and lectures is time-consuming.

**Solution:** Real-time speech recognition with live transcript display, plus export capabilities for documentation workflows.

---

## Target Users

| User Domain | How They Benefit |
|-------------|-----------------|
| **Content Creators** | All-in-one tool for recording, editing, and streaming content |
| **iOS Developers** | Reference implementation for AVFoundation, Vision, and Speech frameworks |
| **Media Professionals** | Quick audio/video capture with professional controls |
| **Educators & Students** | Speech transcription for lectures, OCR for textbook scanning |
| **Accessibility Users** | Text-to-speech, barcode scanning, and OCR for visual assistance |
| **Quality Assurance Teams** | Face detection for UI testing, barcode scanning for inventory |
| **Journalists** | Quick recording, transcription, and document scanning in the field |
| **Retail & Inventory** | Barcode/QR scanning for product identification and tracking |

---

## Initial Setup

### Prerequisites

| Requirement | Version |
|-------------|---------|
| macOS | 15.0+ (Sequoia) |
| Xcode | 26.0+ |
| iOS Deployment Target | 26.0 |
| Swift | 6.0 |

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/your-org/CreatorStudioApp.git
cd CreatorStudioApp

# 2. Open the project
open CreatorStudioApp.xcodeproj

# 3. Select a simulator or device
# iPhone 16 Pro recommended for full feature testing

# 4. Build and run (Cmd + R)
```

### First Launch

1. **Camera Permission** — Required for photo/video capture, face detection, and barcode scanning
2. **Microphone Permission** — Required for audio recording and speech recognition
3. **Speech Recognition Permission** — Required for real-time transcription
4. **Photo Library Permission** — Required for saving and loading media

> All permissions are requested on-demand when you first use a feature. The Settings screen shows permission status badges.

### No External Dependencies

CreatorStudioPro uses **zero third-party libraries**. Every feature is built with native Apple frameworks:

| Framework | Used For |
|-----------|----------|
| AVFoundation | Camera, audio recording, video playback |
| Vision | Face detection, gender classification, OCR, barcode scanning |
| Speech | Real-time speech recognition |
| AVSpeechSynthesizer | Text-to-speech |
| CoreML | Gender classification model support |
| Combine | Reactive data flow between services and views |
| SwiftUI | All user interface |
| UIKit | Camera preview, video player (via UIViewControllerRepresentable) |

---

## Architecture

### High-Level Architecture

```mermaid
graph TB
    subgraph UI["User Interface Layer"]
        CS[Camera Screen]
        MS[Media Library Screen]
        SS[Speech Screen]
        VS[Vision Screen]
        TS[Tools Screen]
    end

    subgraph VM["ViewModel Layer"]
        CVM[CameraViewModel]
        MVMP[MediaPlayerViewModel]
        SVM[SpeechViewModel]
        FDVM[FaceDetectionViewModel]
        OVM[OCRViewModel]
        SCVM[ScannerViewModel]
    end

    subgraph SVC["Service Layer"]
        CAMS[CameraService]
        VRS[VideoRecorderService]
        PCS[PhotoCaptureService]
        ARS[AudioRecorderService]
        APS[AudioPlayerService]
        SRS[SpeechRecognitionService]
        FDS[FaceDetectionService]
        FGC[FaceGenderClassifier]
        OCR[OCRService]
        SCNR[ScannerService]
        STRM[StreamManager]
    end

    subgraph FRAMEWORKS["Apple Frameworks"]
        AVF[AVFoundation]
        VN[Vision]
        SP[Speech]
        ML[CoreML]
        CMP[Combine]
    end

    CS --> CVM
    MS --> MVMP
    SS --> SVM
    VS --> FDVM
    TS --> OVM
    TS --> SCVM

    CVM --> CAMS
    CVM --> VRS
    CVM --> PCS
    MVMP --> APS
    SVM --> SRS
    FDVM --> FDS
    FDVM --> CAMS
    OVM --> OCR
    SCVM --> SCNR
    SCVM --> CAMS

    CAMS --> AVF
    VRS --> AVF
    PCS --> AVF
    FDS --> VN
    FGC --> VN
    OCR --> VN
    SCNR --> VN
    SRS --> SP
    APS --> AVF
    STRM --> AVF
```

### Layer Responsibilities

```mermaid
graph LR
    subgraph UI["UI Layer"]
        A[SwiftUI Views]
        B[UIViewControllerRepresentable]
    end

    subgraph VM["ViewModel Layer"]
        C[ObservableObject]
        D[Published Properties]
        E[User Actions]
    end

    subgraph SVC["Service Layer"]
        F[Business Logic]
        G[Framework Wrappers]
        H[Data Processing]
    end

    subgraph DATA["Data Layer"]
        I[StorageManager]
        J[FileManagerHelper]
        K[Models]
    end

    A -->|Bind| C
    C -->|Call| F
    F -->|Read/Write| I
    I -->|Persist| J
    B -->|Bridge| G
    G -->|Process| H
```

---

## Feature Workflows

### Camera Photo Capture

```mermaid
sequenceDiagram
    participant User
    participant CameraScreen
    participant CameraViewModel
    participant CameraService
    participant PhotoCaptureService
    participant StorageManager

    User->>CameraScreen: Tap capture button
    CameraScreen->>CameraViewModel: capturePhoto()
    CameraViewModel->>PhotoCaptureService: capturePhoto()
    PhotoCaptureService->>PhotoCaptureService: AVCaptureSession.capturePhoto()
    PhotoCaptureService-->>CameraViewModel: didCapture(UIImage)
    CameraViewModel-->>CameraScreen: Show captured image
    User->>CameraScreen: Tap save
    CameraScreen->>CameraViewModel: savePhoto()
    CameraViewModel->>StorageManager: savePhoto(data)
    StorageManager-->>CameraViewModel: URL
    CameraViewModel-->>CameraScreen: Photo saved
```

### Video Recording with Pause/Resume

```mermaid
sequenceDiagram
    participant User
    participant CameraScreen
    participant CameraViewModel
    participant VideoRecorderService
    participant StorageManager

    User->>CameraScreen: Switch to video mode
    CameraScreen->>CameraViewModel: Set mode = .video

    User->>CameraScreen: Tap record button
    CameraScreen->>CameraViewModel: toggleRecording()
    CameraViewModel->>VideoRecorderService: startRecording()
    VideoRecorderService->>VideoRecorderService: Start timer + AVCaptureMovieFileOutput
    VideoRecorderService-->>CameraViewModel: isRecording = true

    User->>CameraScreen: Tap pause
    CameraScreen->>CameraViewModel: pauseRecording()
    CameraViewModel->>VideoRecorderService: pauseRecording()
    Note over VideoRecorderService: Timer frozen, recording continues

    User->>CameraScreen: Tap resume
    CameraScreen->>CameraViewModel: resumeRecording()
    CameraViewModel->>VideoRecorderService: resumeRecording()
    Note over VideoRecorderService: Timer resumes

    User->>CameraScreen: Tap stop
    CameraScreen->>CameraViewModel: toggleRecording()
    CameraViewModel->>VideoRecorderService: stopRecording()
    VideoRecorderService-->>CameraViewModel: didFinishRecording(tempURL)
    CameraViewModel-->>CameraScreen: Show save/discard alert

    alt Save
        User->>CameraScreen: Tap Yes
        CameraScreen->>CameraViewModel: saveVideo()
        CameraViewModel->>StorageManager: saveVideo(from: tempURL)
    else Discard
        User->>CameraScreen: Tap No
        CameraScreen->>CameraViewModel: discardVideo()
        CameraViewModel->>CameraViewModel: Delete temp file
    end
```

### Face Detection with Gender Classification

```mermaid
sequenceDiagram
    participant Camera as Camera Feed
    participant CameraService
    participant FaceDetectionService
    participant FaceGenderClassifier
    participant FaceDetectionViewModel
    participant FaceOverlayView

    loop Every 0.1s (10fps)
        Camera->>CameraService: didOutput(sampleBuffer)
        CameraService->>FaceDetectionService: detectFaces(in: sampleBuffer)
        FaceDetectionService->>FaceDetectionService: VNDetectFaceRectanglesRequest
        FaceDetectionService->>FaceDetectionService: VNDetectFaceLandmarksRequest

        loop For each face
            FaceDetectionService->>FaceDetectionService: Extract landmarks (points)
            FaceDetectionService->>FaceGenderClassifier: classifyGender(boundingBox, landmarks)
            FaceGenderClassifier->>FaceGenderClassifier: Compute face shape features
            FaceGenderClassifier->>FaceGenderClassifier: Count male/female votes
            FaceGenderClassifier->>FaceGenderClassifier: Temporal smoothing (8 frames)
            FaceGenderClassifier-->>FaceDetectionService: .male / .female / .unknown
        end

        FaceDetectionService-->>FaceDetectionViewModel: didDetect(faces)
        FaceDetectionViewModel-->>FaceOverlayView: Update bounding boxes
        Note over FaceOverlayView: Blue border = Male<br/>Pink border = Female<br/>Yellow border = Unknown
    end
```

### OCR Text Extraction

```mermaid
sequenceDiagram
    participant User
    participant OCRScreen
    participant OCRViewModel
    participant ImagePicker
    participant OCRService
    participant Vision

    User->>OCRScreen: Tap "Photo Library" or "Camera"
    OCRScreen->>ImagePicker: Open picker
    ImagePicker-->>OCRScreen: Selected image
    OCRScreen->>OCRViewModel: processImage(uiImage)

    OCRViewModel->>OCRService: recognizeText(in: image)
    OCRService->>Vision: VNRecognizeTextRequest
    Note over Vision: Recognition level: Accurate<br/>Languages: en-US, en-GB<br/>Language correction: ON
    Vision-->>OCRService: [VNRecognizedTextObservation]
    OCRService-->>OCRViewModel: [OCRResult]

    OCRViewModel-->>OCRScreen: Display extracted text
    User->>OCRScreen: Tap "Copy"
    OCRScreen->>OCRScreen: UIPasteboard.general.string = text
```

### QR & Barcode Scanner

```mermaid
sequenceDiagram
    participant Camera as Camera Feed
    participant ScannerService
    participant ScannerViewModel
    participant ScannerScreen

    ScannerScreen->>ScannerViewModel: start()
    ScannerViewModel->>ScannerService: configure(with: session)
    ScannerViewModel->>ScannerService: startScanning()

    loop Every frame
        Camera->>ScannerService: didOutput(sampleBuffer)
        ScannerService->>ScannerService: VNDetectBarcodesRequest
        Note over ScannerService: Symbologies: QR, EAN-13,<br/>EAN-8, Code 128, Code 39,<br/>UPC-E, Codabar

        alt Code detected
            ScannerService->>ScannerService: 2s cooldown check
            ScannerService-->>ScannerViewModel: didDetect(code)
            ScannerViewModel-->>ScannerScreen: Show result
            ScannerScreen->>ScannerScreen: Display type + value
            opt URL detected
                ScannerScreen->>ScannerScreen: Show "Open" button
            end
        end
    end
```

### Speech Recognition

```mermaid
sequenceDiagram
    participant User
    participant TranscriptScreen
    participant SpeechViewModel
    participant SpeechRecognitionService
    participant Speech.framework

    User->>TranscriptScreen: Tap "Start Recording"
    TranscriptScreen->>SpeechViewModel: startRecognition()
    SpeechViewModel->>SpeechRecognitionService: startRecognition()
    SpeechRecognitionService->>Speech.framework: SFSpeechRecognizer.recognitionTask()

    loop Real-time transcription
        Speech.framework-->>SpeechRecognitionService: didFinishRecognition(result)
        SpeechRecognitionService-->>SpeechViewModel: update transcript
        SpeechViewModel-->>TranscriptScreen: Display live text
    end

    User->>TranscriptScreen: Tap "Stop"
    TranscriptScreen->>SpeechViewModel: stopRecognition()
    SpeechViewModel->>SpeechRecognitionService: stopRecognition()
    Speech.framework-->>SpeechRecognitionService: Task completed
```

### Audio Playback with Seek

```mermaid
sequenceDiagram
    participant User
    participant AudioPlayerScreen
    participant MediaPlayerViewModel
    participant AudioPlayerService

    User->>AudioPlayerScreen: Select audio file
    AudioPlayerScreen->>MediaPlayerViewModel: loadAudio(url)
    MediaPlayerViewModel->>AudioPlayerService: load(url)
    AudioPlayerService->>AudioPlayerService: AVAudioPlayer.init(contentsOf:)
    AudioPlayerService-->>MediaPlayerViewModel: duration updated (via Combine)

    User->>AudioPlayerScreen: Tap play
    AudioPlayerScreen->>MediaPlayerViewModel: play()
    MediaPlayerViewModel->>AudioPlayerService: play()

    loop Every 0.1s
        AudioPlayerService->>AudioPlayerService: Timer fires
        AudioPlayerService-->>MediaPlayerViewModel: currentTime updated (via Combine)
        MediaPlayerViewModel-->>AudioPlayerScreen: Slider moves right
        Note over AudioPlayerScreen: Left label: current time<br/>Right label: total duration<br/>Slider: position tracking
    end

    User->>AudioPlayerScreen: Drag slider
    AudioPlayerScreen->>MediaPlayerViewModel: seek(to: time)
    MediaPlayerViewModel->>AudioPlayerService: seek(to: time)
```

### Live Streaming

```mermaid
sequenceDiagram
    participant User
    participant StreamingDebugScreen
    participant StreamManager
    participant NetworkStreamService
    participant AVFoundation
    participant RTMP Server

    User->>StreamingDebugScreen: Enter RTMP URL
    StreamingDebugScreen->>StreamManager: configure(url, streamKey)

    User->>StreamingDebugScreen: Tap "Start Stream"
    StreamingDebugScreen->>NetworkStreamService: startStreaming()
    NetworkStreamService->>AVFoundation: Start AVCaptureSession + encoder
    NetworkStreamService->>RTMP Server: Connect + publish

    loop While streaming
        AVFoundation-->>NetworkStreamService: Encoded frames
        NetworkStreamService->>RTMP Server: Send video/audio data
        NetworkStreamService-->>StreamingDebugScreen: Update statistics
        Note over StreamingDebugScreen: Bitrate, FPS,<br/>Resolution, Duration
    end

    User->>StreamingDebugScreen: Tap "Stop"
    StreamingDebugScreen->>NetworkStreamService: stopStreaming()
    NetworkStreamService->>RTMP Server: Disconnect
```

---

## Project Structure

```
CreatorStudioApp/
├── App/
│   ├── CreatorStudioApp.swift      # App entry point
│   └── AppRouter.swift             # Navigation, tabs, destinations
│
├── Core/
│   ├── Constants/
│   │   ├── AppConstants.swift      # App-wide constants
│   │   ├── PermissionKeys.swift    # Permission key strings
│   │   └── FileNames.swift         # File naming conventions
│   ├── Extensions/
│   │   ├── URL+Extensions.swift
│   │   ├── View+Extensions.swift
│   │   ├── Color+Extensions.swift
│   │   ├── AVCaptureDevice+Extensions.swift
│   │   └── CMSampleBuffer+Extensions.swift
│   ├── Helpers/
│   │   ├── FileManagerHelper.swift # Directory management
│   │   ├── VideoHelper.swift
│   │   ├── AudioHelper.swift
│   │   ├── Logger.swift            # Unified logging
│   │   └── TimeFormatter.swift     # Time display formatting
│   ├── Managers/
│   │   ├── AppStateManager.swift
│   │   ├── NetworkMonitor.swift
│   │   ├── StorageManager.swift    # Photo/video/audio persistence
│   │   └── PermissionCoordinator.swift
│   └── Permissions/
│       ├── CameraPermissionManager.swift
│       ├── MicrophonePermissionManager.swift
│       └── SpeechPermissionManager.swift
│
├── Models/
│   ├── Shared/
│   │   └── MediaType.swift
│   ├── Vision/
│   │   └── FaceModel.swift         # Face + landmarks + gender
│   ├── Audio/
│   │   └── AudioRecordingModel.swift
│   └── ...
│
├── Services/
│   ├── Camera/
│   │   ├── CameraService.swift     # AVCaptureSession management
│   │   ├── PhotoCaptureService.swift
│   │   ├── VideoRecorderService.swift # Pause/resume, save/discard
│   │   └── MultiCamService.swift
│   ├── Audio/
│   │   ├── AudioSessionService.swift
│   │   ├── AudioRecorderService.swift
│   │   ├── AudioPlayerService.swift
│   │   ├── AudioEngineService.swift
│   │   └── AudioAnalyzer.swift
│   ├── Speech/
│   │   ├── SpeechRecognitionService.swift
│   │   └── TextToSpeechService.swift
│   ├── Vision/
│   │   ├── FaceDetectionService.swift   # VNDetectFaceLandmarksRequest
│   │   ├── FaceGenderClassifier.swift   # Heuristic gender classification
│   │   ├── FaceTrackingService.swift    # VNTrackObjectRequest
│   │   ├── OCRService.swift            # VNRecognizeTextRequest
│   │   └── ScannerService.swift        # VNDetectBarcodesRequest
│   ├── Playback/
│   │   └── VideoPlayerService.swift
│   ├── Editing/
│   │   ├── VideoCompositionService.swift
│   │   └── ExportService.swift
│   └── Streaming/
│       ├── StreamEncoder.swift
│       ├── StreamManager.swift
│       └── NetworkStreamService.swift
│
├── UIKitBridge/
│   └── Camera/
│       ├── CameraViewController.swift  # AVCaptureVideoPreviewLayer
│       ├── CameraPreview.swift         # UIViewControllerRepresentable
│       ├── PlayerViewController.swift
│       └── ...
│
├── Features/
│   ├── Camera/
│   │   ├── Screens/
│   │   │   ├── CameraScreen.swift
│   │   │   ├── GalleryScreen.swift
│   │   │   └── PhotoViewerScreen.swift
│   │   ├── ViewModels/
│   │   │   └── CameraViewModel.swift
│   │   └── Components/
│   │       ├── CameraControlsView.swift
│   │       ├── CaptureButton.swift
│   │       ├── CameraToolbar.swift
│   │       └── RecordingTimerView.swift
│   ├── Media/
│   │   └── MediaLibraryScreen.swift
│   ├── Playback/
│   │   ├── Screens/
│   │   │   ├── AudioPlayerScreen.swift
│   │   │   ├── VideoPlayerScreen.swift
│   │   │   └── MediaLibraryScreen.swift
│   │   ├── ViewModels/
│   │   │   └── MediaPlayerViewModel.swift
│   │   └── Components/
│   │       ├── SeekBarView.swift
│   │       └── PlaybackControls.swift
│   ├── Speech/
│   │   ├── Screens/
│   │   │   ├── TranscriptScreen.swift
│   │   │   └── TTSPlaygroundScreen.swift
│   │   └── ViewModels/
│   │       └── SpeechViewModel.swift
│   ├── Vision/
│   │   ├── Screens/
│   │   │   ├── FaceDetectionScreen.swift
│   │   │   ├── FaceTrackingScreen.swift
│   │   │   ├── OCRScreen.swift
│   │   │   └── ScannerScreen.swift
│   │   ├── ViewModels/
│   │   │   ├── FaceDetectionViewModel.swift
│   │   │   └── FaceTrackingViewModel.swift
│   │   └── Components/
│   │       ├── FaceOverlayView.swift
│   │       └── FaceBoundingBox.swift
│   ├── Tools/
│   │   ├── VoiceMemoScreen.swift
│   │   ├── AudioAnalysisScreen.swift
│   │   ├── StreamingDebugScreen.swift
│   │   └── ...
│   ├── Common/
│   │   └── SplashScreen.swift
│   └── VideoRecording/
│       ├── Screens/
│       │   └── VideoRecorderScreen.swift
│       ├── ViewModels/
│       │   └── VideoRecorderViewModel.swift
│       └── Components/
│           └── RecordingTimerView.swift
│
├── Resources/
│   ├── Assets.xcassets/
│   │   ├── AccentColor.colorset/
│   │   └── LaunchScreenBackground.colorset/
│   └── Info.plist
│
└── Tests/
    └── CreatorStudioAppTests/
```

---

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| **UIKit + SwiftUI Bridge** | Camera preview requires `AVCaptureVideoPreviewLayer` (UIKit); all other UI is SwiftUI for modern declarative syntax |
| **Per-Instance Camera Caching** | Static cache caused second `CameraService` instance to skip config; now each instance caches independently |
| **Async Camera Configuration** | `configureSession()` is async/await, called after permission grant, not in `init()` |
| **Heuristic Gender Classification** | No Core ML model bundled; uses face landmark geometry (jaw ratio, nose width, lip fullness, brow shape) with 8-frame temporal smoothing |
| **Video Recording: Save/Discard** | Recording doesn't auto-save; delegates temp URL to caller who decides via alert — prevents accidental storage fills |
| **Zero Dependencies** | All features use native Apple frameworks only — no CocoaPods, SPM, or Carthage |
| **Combine Over Closures** | Service-to-ViewModel communication uses `@Published` + `assign(to:)` for type-safe, leak-resistant bindings |
| **Coordinator Pattern** | `AppCoordinator` manages tab navigation and deep linking via `AppRouter.Destination` enum |

---

## License

This project is proprietary software. All rights reserved.

---

**Built with ❤️ using AVFoundation, Vision, Speech, and SwiftUI**
