import Alamofire
import RxSwift

protocol AuthServiceProtocol {
    func login(socialType: SocialType, token: String) -> Observable<LoginResponse>
}

struct AuthService: AuthServiceProtocol {
    func login(socialType: SocialType, token: String) -> Observable<LoginResponse> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/auth/login"
            let parameters = LoginRequest(socialType: socialType, token: token).params
            let headers = HTTPUtils.jsonHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .post,
                parameters: parameters,
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
}
