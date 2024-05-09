import AuthenticationServices

import RxSwift

protocol AppleSignInManagerProtocol {
    func signIn() -> Observable<SignInResult>
}

final class AppleSigninManager: NSObject, AppleSignInManagerProtocol {
    static let shared = AppleSigninManager()
    
    private var publisher = PublishSubject<SignInResult>()
    
    func signIn() -> Observable<SignInResult> {
        self.publisher = PublishSubject<SignInResult>()
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName]
        let authController = ASAuthorizationController(authorizationRequests: [request])
        
        authController.delegate = self
        authController.performRequests()
        return self.publisher
    }
}

extension AppleSigninManager: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if let authorizationError = error as? ASAuthorizationError {
            switch authorizationError.code {
            case .canceled:
                break
                
            case .failed, .invalidResponse, .notHandled, .unknown:
                let error = BaseError.custom(authorizationError.localizedDescription)
                
                self.publisher.onError(error)
                
            default:
                let error = BaseError.custom(error.localizedDescription)
                
                self.publisher.onError(error)
            }
        } else {
            let error = BaseError.custom("error is instance of \(error.self). not ASAuthorizationError")
            
            self.publisher.onError(error)
        }
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let accessToken = String(data: appleIDCredential.identityToken!, encoding: .utf8) {
            let name = appleIDCredential.fullName?.name
            let signInResult = SignInResult(token: accessToken, name: name)
            
            self.publisher.onNext(signInResult)
            self.publisher.onCompleted()
        } else {
            let signInError = BaseError.custom("credential is not ASAuthorizationAppleIDCredential")
            
            self.publisher.onError(signInError)
        }
    }
}

private extension PersonNameComponents {
    var name: String {
        let firstName = "\(givenName ?? "") "
        let lastName = familyName ?? ""
        return "\(firstName)\(lastName)"
    }
}
