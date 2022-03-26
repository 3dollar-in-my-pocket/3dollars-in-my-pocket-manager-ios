import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class SignupReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case inputOwnerName(String)
        case inputStoreName(String)
        case inputRegisterationNumber(String)
        case inputPhoneNumber(String)
        case selectCategory(index: Int)
        case selectPhoto(UIImage)
        case tapSignup
    }
    
    enum Mutation {
        case setOwnerName(String)
        case setStoreName(String)
        case setRegisterationNumber(String)
        case setPhoneNumber(String)
        case selectCategory(StoreCategory)
        case deselectCategory(StoreCategory)
        case setCategories([StoreCategory])
        case setPhoto(UIImage)
        case setSignupButtonEnable(Bool)
        case showLoading(isShow: Bool)
        case pushWaiting
        case goToSignin
        case showErrorAlert(Error)
    }
    
    struct State {
        var ownerName = ""
        var storeName = ""
        var registerationNumber = ""
        var phoneNumber = ""
        var categories: [StoreCategory] = []
        var selectedCategories: [StoreCategory] = []
        var photo: UIImage?
        var isEnableSignupButton = false
    }
    
    let initialState = State()
    let pushWaitingPublisher = PublishRelay<Void>()
    let goToSigninPublisher = PublishRelay<Void>()
    private let socialType: SocialType
    private let token: String
    private let categoryService: CategoryServiceType
    private let imageService: ImageServiceType
    private let authService: AuthServiceType
    private var userDefaultsUtils: UserDefaultsUtils
    
    init(
        socialType: SocialType,
        token: String,
        categoryService: CategoryServiceType,
        imageService: ImageServiceType,
        authService: AuthServiceType,
        userDefaultsUtils: UserDefaultsUtils
    ) {
        self.socialType = socialType
        self.token = token
        self.categoryService = categoryService
        self.imageService = imageService
        self.authService = authService
        self.userDefaultsUtils = userDefaultsUtils
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchCategories()
            
        case .inputOwnerName(let ownerName):
            return .merge([
                .just(.setOwnerName(ownerName)),
                .just(.setSignupButtonEnable(self.validate(ownerName: ownerName)))
            ])
            
        case .inputStoreName(let storeName):
            return .merge([
                .just(.setStoreName(storeName)),
                .just(.setSignupButtonEnable(self.validate(storeName: storeName)))
            ])
            
        case .inputRegisterationNumber(let registerationNumber):
            return .merge([
                .just(.setRegisterationNumber(registerationNumber)),
                .just(.setSignupButtonEnable(self.validate(registerationNumber: registerationNumber)))
            ])
            
        case .inputPhoneNumber(let phoneNumber):
            return .merge([
                .just(.setPhoneNumber(phoneNumber)),
                .just(.setSignupButtonEnable(self.validate(phoneNumber: phoneNumber)))
            ])
            
        case .selectCategory(let index):
            let selectedCategory = self.currentState.categories[index]
            
            if self.currentState.selectedCategories.contains(selectedCategory) {
                return .just(.deselectCategory(selectedCategory))
            } else {
                return .just(.selectCategory(selectedCategory))
            }
            
        case .selectPhoto(let photo):
            return .merge([
                .just(.setPhoto(photo)),
                .just(.setSignupButtonEnable(self.validate(photo: photo)))
            ])
            
        case .tapSignup:
            return self.signup()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setOwnerName(let ownerName):
            newState.ownerName = ownerName
            
        case .setStoreName(let storeName):
            newState.storeName = storeName
            
        case .setRegisterationNumber(let registerationNumber):
            newState.registerationNumber = registerationNumber
            
        case .setPhoneNumber(let phoneNumber):
            newState.phoneNumber = phoneNumber
            
        case .selectCategory(let category):
            newState.selectedCategories.append(category)
            
        case .deselectCategory(let category):
            if let targetIndex = state.selectedCategories.firstIndex(of: category) {
                newState.selectedCategories.remove(at: targetIndex)
            }
            
        case .setCategories(let categories):
            newState.categories = categories
            
        case .setPhoto(let photo):
            newState.photo = photo
            
        case .setSignupButtonEnable(let isEnable):
            newState.isEnableSignupButton = isEnable
            
        case .showLoading(let isShow):
            self.showLoadginPublisher.accept(isShow)
            
        case .pushWaiting:
            self.pushWaitingPublisher.accept(())
            
        case .goToSignin:
            self.goToSigninPublisher.accept(())
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func validate(
        ownerName: String? = nil,
        storeName: String? = nil,
        registerationNumber: String? = nil,
        phoneNumber: String? = nil,
        photo: UIImage? = nil
    ) -> Bool {
        let ownerName = ownerName ?? self.currentState.ownerName
        let storeName = storeName ?? self.currentState.storeName
        let registerationNumber = registerationNumber ?? self.currentState.registerationNumber
        let phoneNumber = phoneNumber ??  self.currentState.phoneNumber
        let photo = photo ?? self.currentState.photo
        
        return !ownerName.isEmpty
        && !storeName.isEmpty
        && !registerationNumber.isEmpty
        && !phoneNumber.isEmpty
        && photo != nil
    }
    
    private func fetchCategories() -> Observable<Mutation> {
        return self.categoryService.fetchCategories()
            .map { $0.map(StoreCategory.init(response:)) }
            .map { .setCategories($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func signup() -> Observable<Mutation> {
        let ownerName = self.currentState.ownerName
        let storeName = self.currentState.storeName
        let registerationNumber = self.currentState.registerationNumber
        let phoneNumber = self.currentState.phoneNumber
        let categories = self.currentState.selectedCategories
        let photo = self.currentState.photo ?? UIImage()
        let socialType = self.socialType
        let token = self.token
        let signupObservable = self.imageService.uploadImage(image: photo, fileType: .certification)
            .flatMap { [weak self] imageResponse -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                return self.authService.signup(
                    ownerName: ownerName,
                    storeName: storeName,
                    registerationNumber: registerationNumber,
                    phoneNumber: phoneNumber,
                    categories: categories,
                    photoUrl: imageResponse.imageUrl,
                    socialType: socialType,
                    token: token
                )
                .do(onNext: { [weak self] response in
                    self?.userDefaultsUtils.userToken = response.token
                })
                .map { _ in .pushWaiting }
                .catch { error in
                    if let httpError = error as? HTTPError {
                        switch httpError {
                        case .forbidden:
                            return .just(.pushWaiting)
                            
                        case .conflict:
                            return .just(.goToSignin)
                            
                        default:
                            break
                        }
                    }
                    return .merge([
                        .just(.showErrorAlert(error)),
                        .just(.showLoading(isShow: false))
                    ])
                }
            }
            .catch { error in
                return .merge([
                    .just(.showErrorAlert(error)),
                    .just(.showLoading(isShow: false))
                ])
            }
        
        return .concat([
            .just(.showLoading(isShow: true)),
            signupObservable,
            .just(.showLoading(isShow: false))
        ])
    }
}