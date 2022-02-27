import RxSwift
import KakaoSDKUser
import KakaoSDKCommon

protocol KakaoSignInManagerProtocol {
    func signIn() -> Observable<String>
}

final class KakaoSignInManager: KakaoSignInManagerProtocol {
    static let shared = KakaoSignInManager()
    
    /// 카카오톡으로 로그인을 하고 성공하면 token을 반환합니다.
    func signIn() -> Observable<String> {
        return .create { observer in
            if (UserApi.isKakaoTalkLoginAvailable()) {
                self.signInWithKakaoTalk(observer: observer)
            } else {
                self.signInWithKakaoAccount(observer: observer)
            }
            
            return Disposables.create()
        }
    }
    
    /// 카카오톡으로 로그인하기
    private func signInWithKakaoTalk(observer: AnyObserver<String>) {
        UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
            if let sdkError = error as? SdkError {
                if sdkError.isClientFailed {
                    switch sdkError.getClientError().reason {
                    case .Cancelled:
                        break
                        
                    default:
                        let errorMessage = sdkError.getApiError().info?.msg ?? ""
                        let error = BaseError.custom(errorMessage)
                        
                        observer.onError(error)
                    }
                }
            }
            else {
                if let accessToken = oauthToken?.accessToken {
                    observer.onNext(accessToken)
                    observer.onCompleted()
                } else {
                    let error = BaseError.custom("토큰이 비었습니다.")
                    
                    observer.onError(error)
                }
            }
        }
    }
    
    /// 카카오 웹뷰로 로그인하기
    private func signInWithKakaoAccount(observer: AnyObserver<String>) {
        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            if let error = error {
                if let sdkError = error as? SdkError {
                    if sdkError.isClientFailed {
                        switch sdkError.getClientError().reason {
                        case .Cancelled:
                            break
                            
                        default:
                            let errorMessage = sdkError.getApiError().info?.msg ?? ""
                            let error = BaseError.custom(errorMessage)
                            
                            observer.onError(error)
                        }
                    }
                }
            }
            else {
                if let accessToken = oauthToken?.accessToken {
                    observer.onNext(accessToken)
                    observer.onCompleted()
                } else {
                    let error = BaseError.custom("토큰이 비었습니다.")
                    
                    observer.onError(error)
                }
            }
        }
    }
}
