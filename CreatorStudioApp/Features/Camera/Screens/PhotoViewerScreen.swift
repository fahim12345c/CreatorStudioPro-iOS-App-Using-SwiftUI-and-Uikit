import SwiftUI

struct PhotoViewerScreen: View {
    let url: URL
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .ignoresSafeArea()
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationTitle("Photo")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            image = UIImage(contentsOfFile: url.path)
        }
    }
}
