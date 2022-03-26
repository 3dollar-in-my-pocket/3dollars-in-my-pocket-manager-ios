import UIKit

import Alamofire
import RxSwift
import Base

protocol ImageServiceType {
    func uploadImage(image: UIImage, fileType: FileType) -> Observable<ImageUploadResponse>
}

struct ImageService: ImageServiceType {
    func uploadImage(image: UIImage, fileType: FileType) -> Observable<ImageUploadResponse> {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return .error(BaseError.nilValue)
        }
        
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/upload/\(fileType.rawValue)"
            
            HTTPUtils.fileUploadSession.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(
                    data,
                    withName: "file",
                    fileName: DateUtils.todayString(format: "yyyy-MM-dd'T'HH-mm-ss") + "_image.png",
                    mimeType: "image/png"
                )
            }, to: urlString)
                .responseDecodable(of: ResponseContainer<ImageUploadResponse>.self) { response in
                    if response.isSuccess() {
                        observer.processValue(response: response)
                    } else {
                        observer.processHTTPError(response: response)
                    }
                }
            
            return Disposables.create()
        }
    }
}
