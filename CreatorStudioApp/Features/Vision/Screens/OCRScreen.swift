import SwiftUI
import PhotosUI

struct OCRScreen: View {
    @StateObject private var viewModel = OCRViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.selectedImage == nil {
                Spacer()
                VStack(spacing: 20) {
                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.appPrimary)

                    Text("Select an Image")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Choose an image to extract text from")
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryText)

                    HStack(spacing: 16) {
                        Button {
                            sourceType = .photoLibrary
                            showImagePicker = true
                        } label: {
                            Label("Photo Library", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appPrimary)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button {
                            sourceType = .camera
                            showImagePicker = true
                        } label: {
                            Label("Camera", systemImage: "camera.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appSecondaryBackground)
                                .foregroundColor(.appPrimary)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 32)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 250)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }

                        if viewModel.isProcessing {
                            ProgressView("Extracting text...")
                                .padding()
                        } else if !viewModel.extractedText.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Extracted Text")
                                        .font(.headline)
                                    Spacer()
                                    Button {
                                        UIPasteboard.general.string = viewModel.extractedText
                                    } label: {
                                        Label("Copy", systemImage: "doc.on.doc")
                                            .font(.caption)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.appPrimary)
                                }
                                .padding(.horizontal)

                                Text(viewModel.extractedText)
                                    .font(.body)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.appSecondaryBackground)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                        } else if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding(.vertical)
                }

                Button("Select Different Image") {
                    viewModel.clear()
                    selectedItem = nil
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.appSecondaryBackground)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("OCR")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    viewModel.selectedImage = uiImage
                    viewModel.processImage(uiImage)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: sourceType, image: Binding(
                get: { viewModel.selectedImage },
                set: { viewModel.selectedImage = $0; if let img = $0 { viewModel.processImage(img) } }
            ))
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

@MainActor
final class OCRViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var extractedText = ""
    @Published var isProcessing = false
    @Published var errorMessage = ""

    private let ocrService = OCRService()

    func processImage(_ image: UIImage) {
        isProcessing = true
        extractedText = ""
        errorMessage = ""

        ocrService.recognizeText(in: image) { [weak self] results in
            DispatchQueue.main.async {
                self?.isProcessing = false
                if results.isEmpty {
                    self?.errorMessage = "No text found in the image."
                } else {
                    self?.extractedText = results.map(\.text).joined(separator: "\n")
                }
            }
        }
    }

    func clear() {
        selectedImage = nil
        extractedText = ""
        errorMessage = ""
    }
}
