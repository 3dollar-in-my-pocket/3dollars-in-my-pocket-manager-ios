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
        case pushWaiting
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
    private let categoryService: CategoryServiceType
    
    init(categoryService: CategoryServiceType) {
        self.categoryService = categoryService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchCategories()
            
        case .inputOwnerName(let ownerName):
            return .just(.setOwnerName(ownerName))
            
        case .inputStoreName(let storeName):
            return .just(.setStoreName(storeName))
            
        case .inputRegisterationNumber(let registerationNumber):
            return .just(.setRegisterationNumber(registerationNumber))
            
        case .inputPhoneNumber(let phoneNumber):
            return .just(.setPhoneNumber(phoneNumber))
            
        case .selectCategory(let index):
            let selectedCategory = self.currentState.categories[index]
            
            if self.currentState.selectedCategories.contains(selectedCategory) {
                return .just(.deselectCategory(selectedCategory))
            } else {
                return .just(.selectCategory(selectedCategory))
            }
            
        case .selectPhoto(let photo):
            return .just(.setPhoto(photo))
            
        case .tapSignup:
            if self.validate(
                ownerName: self.currentState.ownerName,
                storeName: self.currentState.storeName,
                registerationNumber: self.currentState.registerationNumber,
                photo: self.currentState.photo
            ) {
                // 회원가입
                return .empty()
            } else {
                // 에러
                return .empty()
            }
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
            
        case .pushWaiting:
            self.pushWaitingPublisher.accept(())
            
        case .showErrorAlert(let error):
            self.showErrorAlert.accept(error)
        }
        
        return newState
    }
    
    private func validate(
        ownerName: String,
        storeName: String,
        registerationNumber: String,
        photo: UIImage?
    ) -> Bool {
        return !ownerName.isEmpty
        && !storeName.isEmpty
        && !registerationNumber.isEmpty
        && photo != nil
    }
    
    private func fetchCategories() -> Observable<Mutation> {
        return self.categoryService.fetchCategories()
            .map { $0.map(StoreCategory.init(response:)) }
            .map { .setCategories($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
}
