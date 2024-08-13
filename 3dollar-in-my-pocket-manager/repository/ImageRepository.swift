import UIKit

import Alamofire

protocol ImageRepository {
    func uploadImages(
        images: [UIImage],
        fileType: FileType, 
        imageType: ImageType
    ) async -> ApiResult<[ImageUploadResponse]>
}

final class ImageRepositoryImpl: ImageRepository {
    func uploadImages(images: [UIImage], fileType: FileType, imageType: ImageType) async -> ApiResult<[ImageUploadResponse]> {
        return await ImageApi.uploadImages(images: images, fileType: fileType).asyncRequest()
    }
}
