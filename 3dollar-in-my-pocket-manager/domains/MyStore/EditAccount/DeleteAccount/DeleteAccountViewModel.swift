import Foundation
import Combine

extension DeleteAccountViewModel {
    struct Input {
        let didTapDelete = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
        let successDeleteAccountNumber = PassthroughSubject<Void, Never>()
        let toast = PassthroughSubject<String, Never>()
    }
    
    enum Route {
        case dismiss
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        let preference: Preference
        
        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            preference: Preference = .shared
        ) {
            self.storeRepository = storeRepository
            self.preference = preference
        }
    }
}

final class DeleteAccountViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private let dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.didTapDelete
            .withUnretained(self)
            .sink { (owner: DeleteAccountViewModel, _) in
                owner.deleteAccountNumbers()
            }
            .store(in: &cancellables)
    }
    
    private func deleteAccountNumbers() {
        Task {
            let storeId = dependency.preference.storeId
            let request = BossStorePatchRequest(accountNumbers: [])
            
            let result = await dependency.storeRepository.editStore(storeId: storeId, request: request)
            
            switch result {
            case .success(_):
                output.route.send(.dismiss)
                output.toast.send(Strings.DeleteAccount.toast)
                output.successDeleteAccountNumber.send(())
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
}
