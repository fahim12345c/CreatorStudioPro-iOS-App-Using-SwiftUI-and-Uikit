import AVFoundation
import CoreImage

extension CMSampleBuffer {
    var cgImage: CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(self) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        return context.createCGImage(ciImage, from: ciImage.extent)
    }

    var pixelBuffer: CVPixelBuffer? {
        CMSampleBufferGetImageBuffer(self)
    }

    var presentationTime: CMTime {
        CMSampleBufferGetPresentationTimeStamp(self)
    }

    var duration: CMTime {
        CMSampleBufferGetDuration(self)
    }

    func toCGImage() -> CGImage? {
        cgImage
    }
}
