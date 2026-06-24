import SwiftUI

struct GalleryScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var photos: [PhotoModel] = []
    @State private var videos: [VideoModel] = []
    @State private var selectedTab: MediaType = .photo

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
                    if selectedTab == .photo {
                        ForEach(photos) { item in
                            NavigationLink(value: AppRouter.Destination.photoViewer(url: item.url)) {
                                thumbnailView(for: item as Any)
                            }
                        }
                    } else {
                        ForEach(videos) { item in
                            NavigationLink(value: AppRouter.Destination.videoPlayer(video: item)) {
                                thumbnailView(for: item as Any)
                            }
                        }
                    }
                }
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Gallery")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .onAppear { loadMedia() }
    }

    @ViewBuilder
    private func thumbnailView(for item: Any) -> some View {
        if let photo = item as? PhotoModel {
            if let image = photo.thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
            }
        } else if let video = item as? VideoModel {
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
    }

    private func loadMedia() {
        let storage = StorageManager.shared
        photos = storage.loadAllRecordings()
            .filter { $0.pathExtension == "jpg" || $0.pathExtension == "jpeg" || $0.pathExtension == "png" }
            .map { PhotoModel(url: $0) }
        videos = storage.loadAllRecordings()
            .filter { $0.pathExtension == "mp4" || $0.pathExtension == "mov" }
            .map { VideoModel(url: $0) }
    }
}
