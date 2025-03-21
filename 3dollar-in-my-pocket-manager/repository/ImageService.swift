import UIKit

import Alamofire
import RxSwift

protocol ImageServiceType {
    func uploadImage(image: UIImage, fileType: FileType) -> Observable<ImageUploadResponse>
    
    func uploadImages(images: [UIImage], fileType: FileType) -> Observable<[ImageUploadResponse]>
    
    func uploadImage(image: UIImage, fileType: FileType) async -> ApiResult<ImageUploadResponse>
    
    func uploadImages(images: [UIImage], fileType: FileType) async -> ApiResult<[ImageUploadResponse]>
}

final class ImageService: ImageServiceType {
    enum Constant {
        static let compressionQuality = 0.8
    }
    
    
    func uploadImage(image: UIImage, fileType: FileType) -> Observable<ImageUploadResponse> {
        guard let imageData = image.jpegData(compressionQuality: Constant.compressionQuality) else {
            return .error(BaseError.nilValue)
        }
        
        guard let downsampledDatas = ImageUtil.downsampledImage(data: imageData, size: CGSize(width: 1024, height: 1024))?.jpegData(compressionQuality: 1) else {
            return .error(BaseError.nilValue)
        }
        
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/upload/\(fileType.rawValue)"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.fileUploadSession.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(
                    downsampledDatas,
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
            guard let data = image.jpegData(compressionQuality: Constant.compressionQuality) else {
                return .error(BaseError.nilValue)
            }
            
            datas.append(data)
        }
        
        let downsampledDatas = datas.compactMap { data -> Data? in
            return ImageUtil.downsampledImage(data: data, size: CGSize(width: 1024, height: 1024))?.jpegData(compressionQuality: 1)
        }
        
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/upload/\(fileType.rawValue)/bulk"
            
            HTTPUtils.fileUploadSession.upload(multipartFormData: { multipartFormData in
                for index in downsampledDatas.indices {
                    multipartFormData.append(
                        downsampledDatas[index],
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
    
    func uploadImage(image: UIImage, fileType: FileType) async -> ApiResult<ImageUploadResponse> {
        guard let data = image.jpegData(compressionQuality: Constant.compressionQuality) else {
            return .failure(BaseError.nilValue)
        }
        
        guard let downsampledDatas = ImageUtil.downsampledImage(data: data, size: CGSize(width: 1024, height: 1024))?.jpegData(compressionQuality: 1) else {
            return .failure(BaseError.nilValue)
        }
        
        let urlString = HTTPUtils.url + "/boss/v1/upload/\(fileType.rawValue)"
        let headers = HTTPUtils.defaultHeader()
        
        let result = await AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(
                downsampledDatas,
                withName: "file",
                fileName: DateUtils.todayString(format: "yyyy-MM-dd'T'HH-mm-ss") + "_image.png",
                mimeType: "image/png"
            )
        }, to: urlString, headers: headers).serializingData().result
        
        switch result {
        case .success(let data):
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(ApiResponse<ImageUploadResponse>.self, from: data)
                
                if apiResponse.error.isNotNil,
                    let errorMessage = apiResponse.message {
                    return .failure(ApiError.serverError(errorMessage))
                }
                
                guard let decodableData = apiResponse.data else {
                    return .failure(ApiError.emptyData)
                }
                
                return .success(decodableData)
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
        
    }
    
    func uploadImages(images: [UIImage], fileType: FileType) async -> ApiResult<[ImageUploadResponse]> {
        var datas: [Data] = []
        let urlString = HTTPUtils.url + "/boss/v1/upload/\(fileType.rawValue)/bulk"
        let headers = HTTPUtils.defaultHeader()
        
        
        for image in images {
            guard let data = image.jpegData(compressionQuality: Constant.compressionQuality) else {
                return .failure(BaseError.nilValue)
            }
            
            datas.append(data)
        }
        
        let downsampledDatas = datas.compactMap { data -> Data? in
            return ImageUtil.downsampledImage(data: data, size: CGSize(width: 1024, height: 1024))?.jpegData(compressionQuality: 1)
        }
        
        let result = await AF.upload(multipartFormData: { multipartFormData in
            for index in downsampledDatas.indices {
                multipartFormData.append(
                    downsampledDatas[index],
                    withName: "files",
                    fileName: DateUtils.todayString(format: "yyyy-MM-dd'T'HH-mm-ss") + "_image\(index).png",
                    mimeType: "image/png"
                )
                
            }
        }, to: urlString, headers: headers).serializingData().result
        
        switch result {
        case .success(let data):
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(ApiResponse<[ImageUploadResponse]>.self, from: data)
                
                if apiResponse.error.isNotNil,
                    let errorMessage = apiResponse.message {
                    return .failure(ApiError.serverError(errorMessage))
                }
                
                guard let decodableData = apiResponse.data else {
                    return .failure(ApiError.emptyData)
                }
                
                return .success(decodableData)
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
