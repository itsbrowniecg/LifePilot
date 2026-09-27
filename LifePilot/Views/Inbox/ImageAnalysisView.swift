import SwiftUI
import UIKit

struct ImageAnalysisView: View {
    let image: UIImage
    let aiService: any AIServiceProtocol
    let onFinished: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var errorMessage: String?
    @State private var isWorking = true
    @State private var response: AIAnalysisResponse?

    var body: some View {
        NavigationStack {
            Group {
                if isWorking { ProgressView("Reading your capture…") }
                else if let errorMessage {
                    ContentUnavailableView("We couldn’t read this automatically.", systemImage: "text.viewfinder", description: Text(errorMessage))
                } else { ContentUnavailableView("Ready to review", systemImage: "checkmark.circle") }
            }
            .navigationTitle("LifePilot Capture")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
            .task { await analyzeImage() }
            .sheet(isPresented: Binding(get: { response != nil }, set: { if !$0 { response = nil } })) {
                if let response { CaptureConfirmationView(response: response, sourceText: text) { onFinished(); dismiss() } }
            }
        }
    }

    private func analyzeImage() async {
        do {
            text = try await OCRService.recognizeText(in: image)
            response = await aiService.analyze(capturedText: text)
        } catch {
            errorMessage = error.localizedDescription
        }
        isWorking = false
    }
}
