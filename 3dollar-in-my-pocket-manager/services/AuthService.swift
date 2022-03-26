import Alamofire
import RxSwift
import UIKit

protocol AuthServiceType {
    func login(socialType: SocialType, token: String) -> Observable<LoginResponse>
    
    func signup(
        ownerName: String,
        storeName: String,
        registerationNumber: String,
        phoneNumber: String,
        categories: [StoreCategory],
        photoUrl: String,
        socialType: SocialType,
        token: String
    ) -> Observable<LoginResponse>
    
    func fetchMyInfo() -> Observable<BossAccountInfoResponse>
}

struct AuthService: AuthServiceType {
    func login(socialType: SocialType, token: String) -> Observable<LoginResponse> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/auth/login"
            let parameters = LoginRequest(socialType: socialType, token: token).params
            let headers = HTTPUtils.jsonHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            ).responseDecodable(of: ResponseContainer<LoginResponse>.self) { response in
                if response.isSuccess() {
                    observer.processValue(response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func signup(
        ownerName: String,
        storeName: String,
        registerationNumber: String,
        phoneNumber: String,
        categories: [StoreCategory],
        photoUrl: String,
        socialType: SocialType,
        token: String
    ) -> Observable<LoginResponse> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/auth/signup"
            let parameters = SignupRequest(
                bossName: ownerName,
                businessNumber: registerationNumber,
                certificationPhotoUrl: photoUrl,
                contactsNumber: phoneNumber,
                socialType: socialType,
                storeCategoriesIds: categories.map { $0.categoryId },
                storeName: storeName,
                token: token
            ).params
            let headers = HTTPUtils.jsonHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            ).responseDecodable(of: ResponseContainer<LoginResponse>.self) { response in
                if response.isSuccess() {
                    observer.processValue(response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchMyInfo() -> Observable<BossAccountInfoResponse> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/account/my-info"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: headers
            ).responseDecodable(of: ResponseContainer<BossAccountInfoResponse>.self) { response in
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
