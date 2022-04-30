import Foundation
import RxSwift

final class GlobalState {
    static let shared = GlobalState()
    
    /// 가게 정보 업데이트 리스너
    let updateStorePublisher = PublishSubject<Store>()
}
