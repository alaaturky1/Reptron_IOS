//
//  SampleBufferJPEGExporter.swift
//  SupplementStore
//

import AVFoundation
import CoreImage
import UIKit

enum SampleBufferJPEGExporter {
    /// Downscaled JPEG for network analyze calls.
    static func jpegData(from sampleBuffer: CMSampleBuffer, maxPixelSize: CGFloat = 480, quality: CGFloat = 0.52) -> Data? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext(options: [.useSoftwareRenderer: false])
        let scale = min(maxPixelSize / max(ciImage.extent.width, ciImage.extent.height), 1)
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage.jpegData(compressionQuality: quality)
    }
}
