import RxSwift
import Alamofire

protocol FeedbackServiceType {
    func fetchTotalStatistics(storeId: String) -> Observable<[BossStoreFeedbackCountResponse]>
}

struct FeedbackService: FeedbackServiceType {
    func fetchTotalStatistics(storeId: String) -> Observable<[BossStoreFeedbackCountResponse]> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/store/\(storeId)/feedbacks/full"
            let headers = HTTPUtils.jsonHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: headers
            ).responseDecodable(
                of: ResponseContainer<[BossStoreFeedbackCountResponse]>.self
            ) { response in
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
