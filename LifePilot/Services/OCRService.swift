import UIKit
@preconcurrency import Vision

enum OCRServiceError: LocalizedError {
    case invalidImage
    case noTextFound

    var errorDescription: String? {
        switch self {
        case .invalidImage: "We couldn't read this image."
        case .noTextFound: "We couldn't find readable text in this image."
        }
    }
}

enum OCRService {
    static func recognizeText(in image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else { throw OCRServiceError.invalidImage }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let text = (request.results as? [VNRecognizedTextObservation])?
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                guard !text.isEmpty else {
                    continuation.resume(throwing: OCRServiceError.noTextFound)
                    return
                }
                continuation.resume(returning: text)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
