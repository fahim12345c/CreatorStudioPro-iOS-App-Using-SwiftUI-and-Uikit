import Vision
import UIKit

final class OCRService {

    struct OCRResult {
        let text: String
        let confidence: Float
        let boundingBox: CGRect
    }

    func recognizeText(in image: UIImage, completion: @escaping ([OCRResult]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard error == nil,
                  let observations = request.results as? [VNRecognizedTextObservation] else {
                completion([])
                return
            }

            let results: [OCRResult] = observations.compactMap { observation in
                guard let topCandidate = observation.topCandidates(1).first else { return nil }
                return OCRResult(
                    text: topCandidate.string,
                    confidence: topCandidate.confidence,
                    boundingBox: observation.boundingBox
                )
            }

            completion(results)
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US", "en-GB"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            Logger.error("OCR recognition failed", category: .vision, error: error)
            completion([])
        }
    }
}
