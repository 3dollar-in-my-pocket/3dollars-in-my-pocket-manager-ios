import UIKit

import Alamofire
import RxSwift
import Base

protocol ImageServiceType {
    func uploadImage(image: UIImage, fileType: FileType) -> Observable<ImageUploadResponse>
    
    func uploadImages(images: [UIImage], fileType: FileType) -> Observable<[ImageUploadResponse]>
}

struct ImageService: ImageServiceType {
    func uploadImage(image: UIImage, fileType: FileType) -> Observable<ImageUploadResponse> {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return .error(BaseError.nilValue)
        }
        
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/upload/\(fileType.rawValue)"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.fileUploadSession.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(
                    data,
                    withName: "file",
                    fileName: DateUtils.todayString(format: "yyyy-MM-dd'T'HH-mm-ss") + "_image.png",
                    mimeType: "image/png"
                )
            }, to: urlString, headers: headers)
            .responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(type: ImageUploadResponse.self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
    
    func uploadImages(images: [UIImage], fileType: FileType) -> Observable<[ImageUploadResponse]> {
        var datas: [Data] = []
        let headers = HTTPUtils.defaultHeader()
        
        for image in images {
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                return .error(BaseError.nilValue)
            }
            
            datas.append(data)
        }
        
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/upload/\(fileType.rawValue)/bulk"
            
            HTTPUtils.fileUploadSession.upload(multipartFormData: { multipartFormData in
                for index in datas.indices {
                    multipartFormData.append(
                        datas[index],
                        withName: "files",
                        fileName: DateUtils.todayString(format: "yyyy-MM-dd'T'HH-mm-ss") + "_image\(index).png",
                        mimeType: "image/png"
                    )
                }
            }, to: urlString, headers: headers)
            .responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(type: [ImageUploadResponse].self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
}
