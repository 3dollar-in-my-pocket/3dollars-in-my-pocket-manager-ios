import UIKit

import Alamofire
import RxSwift

protocol ImageServiceType {
    func uploadImage(image: UIImage) -> Observable<ImageUploadResponse>
}

struct ImageService: ImageServiceType {
    func uploadImage(image: UIImage) -> Observable<ImageUploadResponse> {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return .error(BaseError.nilValue)
        }
        
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/upload/"
            
            HTTPUtils.fileUploadSession.upload(data, to: urlString)
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
