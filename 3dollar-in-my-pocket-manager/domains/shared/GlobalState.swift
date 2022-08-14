import Foundation
import RxSwift

final class GlobalState {
    static let shared = GlobalState()
    
    /// 가게 정보 업데이트 리스너
    let updateStorePublisher = PublishSubject<Store>()
    
    /// 리뷰 개수 업데이트 리스너
    let updateReviewCountPublisher = PublishSubject<Int>()
}
