import SwiftUI
import PhotosUI
import AVFoundation

struct AddToLifePilotView: View {
    let aiService: any AIServiceProtocol
    @Environment(\.dismiss) private var dismiss
    @State private var photoItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var showCamera = false
    @State private var showText = false
    @State private var showAnalysis = false
    @State private var notice: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button { openCamera() } label: { Label("Scan Something", systemImage: "camera") }
                    PhotosPicker(selection: $photoItem, matching: .images) { Label("Choose Photo", systemImage: "photo.on.rectangle") }
                    Button { showText = true } label: { Label("Type Something", systemImage: "square.and.pencil") }
                } footer: { Text("LifePilot keeps capture local and asks before saving anything.") }
                if let notice { Section { Label(notice, systemImage: "info.circle") } }
            }
            .navigationTitle("Add to LifePilot")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
            .onChange(of: photoItem) { _, item in Swift.Task { await loadPhoto(item) } }
            .sheet(isPresented: $showText) { CaptureView(aiService: aiService) }
            .fullScreenCover(isPresented: $showCamera) { CameraPicker(onImage: { captured in image = captured; showCamera = false; showAnalysis = true }, onCancel: { showCamera = false }) }
            .sheet(isPresented: $showAnalysis) { if let image { ImageAnalysisView(image: image, aiService: aiService) { dismiss() } } }
        }
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { notice = "Camera is unavailable. Choose a photo or enter details manually."; return }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted: notice = "Camera access is optional. Choose a photo or enter details manually."
        default: showCamera = true
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) async {
        guard let data = try? await item?.loadTransferable(type: Data.self), let loaded = UIImage(data: data) else { return }
        image = loaded
        showAnalysis = true
    }
}
