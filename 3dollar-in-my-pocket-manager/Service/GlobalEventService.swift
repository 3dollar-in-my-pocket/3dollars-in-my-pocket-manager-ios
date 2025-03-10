import Combine

protocol GlobalEventServiceType {
    var didUpdateReview: PassthroughSubject<StoreReviewResponse, Never> { get }
}

final class GlobalEventService: GlobalEventServiceType {
    static let shared = GlobalEventService()
    
    let didUpdateReview = PassthroughSubject<StoreReviewResponse, Never>()
}
