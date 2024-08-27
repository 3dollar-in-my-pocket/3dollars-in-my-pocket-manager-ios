import UIKit

import Alamofire

protocol ImageRepository {
    func uploadImages(
        images: [UIImage],
        fileType: FileType, 
        imageType: ImageType
    ) async -> ApiResult<[BossStoreImage]>
}

final class ImageRepositoryImpl: ImageRepository {
    func uploadImages(images: [UIImage], fileType: FileType, imageType: ImageType) async -> ApiResult<[BossStoreImage]> {
        return await ImageApi.uploadImages(images: images, fileType: fileType).asyncRequest()
    }
}
