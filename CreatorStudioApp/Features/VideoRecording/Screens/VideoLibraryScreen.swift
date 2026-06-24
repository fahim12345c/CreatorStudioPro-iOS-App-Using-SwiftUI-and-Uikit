import SwiftUI

struct VideoLibraryScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var videos: [VideoModel] = []

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                ForEach(videos) { video in
                    NavigationLink(destination: VideoPlayerScreen(video: video)) {
                        ZStack(alignment: .bottomLeading) {
                            if let thumbnail = video.thumbnail {
                                Image(uiImage: thumbnail)
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
            }
        }
        .navigationTitle("Video Library")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .onAppear {
            videos = StorageManager.shared.loadAllRecordings()
                .filter { $0.pathExtension == "mp4" || $0.pathExtension == "mov" }
                .map { VideoModel(url: $0) }
        }
    }
}
