import Alamofire
import RxSwift
import UIKit

protocol AuthServiceType {
    func login(socialType: SocialType, token: String) -> Observable<LoginResponse>
    
    func logout(input: BossLogOutRequest) -> Observable<String>
    
    func signup(
        ownerName: String,
        storeName: String,
        registerationNumber: String,
        categories: [StoreCategory],
        photoUrl: String,
        socialType: SocialType,
        token: String
    ) -> Observable<LoginResponse>
    
    func signout() -> Observable<String>
    
    func fetchMyInfo() -> Observable<BossAccountInfoResponse>
    
    func signinDemo(code: String) -> Observable<LoginResponse>
}

struct AuthService: AuthServiceType {
    func login(socialType: SocialType, token: String) -> Observable<LoginResponse> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/auth/login"
            let parameters = LoginRequest(socialType: socialType, token: token).params
            let headers = HTTPUtils.jsonHeader()
            
            HTTPUtils.loginSession.request(
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
    
    func logout(input: BossLogOutRequest) -> Observable<String> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/auth/logout"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .post,
                parameters: input,
                encoder: JSONParameterEncoder.default,
                headers: headers
            )
            .responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(type: String.self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
    
    func signup(
        ownerName: String,
        storeName: String,
        registerationNumber: String,
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
            )
            .responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(type: LoginResponse.self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
    
    func signout() -> Observable<String> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/auth/signout"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .delete,
                headers: headers
            )
            .responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(type: String.self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
    
    func fetchMyInfo() -> Observable<BossAccountInfoResponse> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/account/me"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: headers
            )
            .responseDecodable(of: ResponseContainer<BossAccountInfoResponse>.self) { response in
                if response.isSuccess() {
                    observer.processValue(response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func signinDemo(code: String) -> Observable<LoginResponse> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/login/demo"
            let headers = HTTPUtils.jsonHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .post,
                parameters: ["code": code],
                headers: headers
            )
            .responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(type: LoginResponse.self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
}
