import UIKit

final class ImageUtil {
    static func downsampledImage(data: Data?, size: CGSize, cacheImmediately: Bool = true) -> UIImage? {
        guard let data = data else { return nil }
        let createOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        return downsampledImage(source: CGImageSourceCreateWithData(data as CFData, createOptions),
                                size: size,
                                cacheImmediately: cacheImmediately)
    }

    static func downsampledImage(source: CGImageSource?, size: CGSize, cacheImmediately: Bool = true) -> UIImage? {
        guard let imageSource = source else {
            return nil
        }
        let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                  kCGImageSourceShouldCacheImmediately: cacheImmediately,
                                  kCGImageSourceCreateThumbnailWithTransform: true,
                                  kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)] as CFDictionary
        guard let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions) else {
            return nil
        }
        return UIImage(cgImage: image)
    }
}
