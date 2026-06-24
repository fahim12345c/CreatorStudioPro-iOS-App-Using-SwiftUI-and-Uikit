import SwiftUI

struct MediaLibraryScreen: View {
    @State private var photos: [PhotoModel] = []
    @State private var videos: [VideoModel] = []
    @State private var audioFiles: [AudioRecordingModel] = []
    @State private var selectedTab: MediaType = .video
    @State private var itemToDelete: AnyIdentifiable?
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(spacing: 0) {
            Picker("Media", selection: $selectedTab) {
                ForEach(MediaType.allCases) { type in
                    Label(type.rawValue, systemImage: type.iconName)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                    ForEach(currentItems) { item in
                        NavigationLink(destination: destinationView(for: item)) {
                            thumbnailView(for: item)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        itemToDelete = item
                                        showDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Media Library")
        .onAppear { loadMedia() }
        .alert("Delete \(selectedTab.rawValue)?", isPresented: $showDeleteAlert, presenting: itemToDelete) { item in
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { deleteItem(item) }
        } message: { _ in
            Text("This action cannot be undone.")
        }
    }

    private var currentItems: [AnyIdentifiable] {
        switch selectedTab {
        case .photo:
            return photos.map { AnyIdentifiable($0) }
        case .video:
            return videos.map { AnyIdentifiable($0) }
        case .audio:
            return audioFiles.map { AnyIdentifiable($0) }
        }
    }

    @ViewBuilder
    private func thumbnailView(for item: AnyIdentifiable) -> some View {
        switch selectedTab {
        case .photo:
            if let photo = item.base as? PhotoModel, let image = photo.thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
            }
        case .video:
            if let video = item.base as? VideoModel {
                ZStack(alignment: .bottomLeading) {
                    if let image = video.thumbnail {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                    }
                    Text(video.formattedDuration)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(4)
                        .background(.black.opacity(0.6))
                        .cornerRadius(4)
                        .padding(4)
                }
            }
        case .audio:
            if let audio = item.base as? AudioRecordingModel {
                VStack {
                    Image(systemName: "waveform")
                        .font(.largeTitle)
                        .foregroundColor(.appPrimary)
                    Text(audio.formattedDuration)
                        .font(.caption)
                    Text(TimeFormatter.formatRelativeDate(audio.creationDate))
                        .font(.caption2)
                        .foregroundColor(.appSecondaryText)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color.appSecondaryBackground)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for item: AnyIdentifiable) -> some View {
        switch selectedTab {
        case .video:
            if let video = item.base as? VideoModel {
                VideoPlayerScreen(video: video)
            }
        case .audio:
            if let audio = item.base as? AudioRecordingModel {
                AudioPlayerScreen(audio: audio)
            }
        case .photo:
            if let photo = item.base as? PhotoModel {
                PhotoViewerScreen(url: photo.url)
            }
        }
    }

    private func loadMedia() {
        let storage = StorageManager.shared
        photos = storage.loadAllRecordings()
            .filter { $0.pathExtension == "jpg" || $0.pathExtension == "jpeg" }
            .map { PhotoModel(url: $0) }
        videos = storage.loadAllRecordings()
            .filter { $0.pathExtension == "mp4" || $0.pathExtension == "mov" }
            .map { VideoModel(url: $0) }
        audioFiles = storage.loadAllAudioFiles()
            .map { AudioRecordingModel(url: $0, duration: AudioHelper.duration(for: $0)) }
    }

    private func deleteItem(_ item: AnyIdentifiable) {
        let url: URL?
        switch selectedTab {
        case .photo:
            url = (item.base as? PhotoModel)?.url
        case .video:
            url = (item.base as? VideoModel)?.url
        case .audio:
            url = (item.base as? AudioRecordingModel)?.url
        }
        guard let fileURL = url else { return }
        StorageManager.shared.deleteFile(at: fileURL)
        loadMedia()
    }
}

struct AnyIdentifiable: Identifiable {
    let id: UUID
    let base: Any

    init<T: Identifiable>(_ base: T) {
        self.id = UUID()
        self.base = base
    }
}
