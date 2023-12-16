import RxSwift
import RxCocoa

class BaseReactor {
    let relayDisposeBag = DisposeBag()
    let showErrorAlert = PublishRelay<Error>()
    let showLoadginPublisher = PublishRelay<Bool>()
}
