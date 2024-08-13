import UIKit

import Alamofire

protocol ImageRequestable: ApiRequest {
    var images: [UIImage] { get }
    var imageType: ImageType { get }
}

enum ImageType: String {
    case jpeg
    case png
    
    var mimeType: String {
        switch self {
        case .jpeg:
            return "image/jpeg"
        case .png:
            return "image/png"
        }
    }
}

extension ImageRequestable {
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Alamofire.Parameters? {
        return nil
    }
    
    var imageData: [Data] {
        switch imageType {
        case .jpeg:
            return images.compactMap { $0.jpegData(compressionQuality: 0.8) }
        case .png:
            return images.compactMap { $0.pngData() }
        }
    }
    
    var imageRequest: DataRequest {
        return AF.upload(multipartFormData: { multipartFormData in
            for (index, imageData) in imageData.enumerated() {
                multipartFormData.append(
                    imageData,
                    withName: "file",
                    fileName: DateUtils.todayString(format: "yyyy-MM-dd'T'HH-mm-ss") + "_image\(index).\(imageType.rawValue)",
                    mimeType: imageType.mimeType
                )
            }
        }, to: baseUrl + path, headers: headers)
    }
    
    func asyncRequest() async -> ApiResult<[ImageUploadResponse]> {
        let result = await imageRequest.serializingData().result
        
        switch result {
        case .success(let data):
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(ApiResponse<[ImageUploadResponse]>.self, from: data)
                
                if let errorMessage = apiResponse.message {
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
            print("[Error] [\(#function)]: \(error)")
            return .failure(error)
        }
    }
}
