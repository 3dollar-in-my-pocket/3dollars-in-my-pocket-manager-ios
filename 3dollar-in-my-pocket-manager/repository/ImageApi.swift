import UIKit

import Alamofire

enum ImageApi {
    case uploadImages(images: [UIImage], fileType: FileType)
}

extension ImageApi: ImageRequestable {
    var path: String {
        switch self {
        case .uploadImages(_, let fileType):
            return "/v1/upload/\(fileType.rawValue)/bulk"
        }
    }
    
    var images: [UIImage] {
        switch self {
        case .uploadImages(let images, _):
            return images
        }
    }
    
    var imageType: ImageType {
        switch self {
        case .uploadImages:
            return .jpeg
        }
    }
}
