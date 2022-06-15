import Foundation

import RxSwift
import Alamofire
import Base

protocol FeedbackServiceType {
    func fetchFeedbackTypes() -> Observable<[BossStoreFeedbackTypeResponse]>
    
    func fetchTotalStatistics(storeId: String) -> Observable<[BossStoreFeedbackCountResponse]>
    
    func fetchDailyStatistics(
        storeId: String,
        startDate: Date,
        endDate: Date
    ) -> Observable<BossStoreFeedbackCursorResponse>
}

struct FeedbackService: FeedbackServiceType {
    func fetchFeedbackTypes() -> Observable<[BossStoreFeedbackTypeResponse]> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/store/feedback/types"
            let headers = HTTPUtils.jsonHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: headers
            ).responseDecodable(
                of: ResponseContainer<[BossStoreFeedbackTypeResponse]>.self
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
    
    func fetchDailyStatistics(
        storeId: String,
        startDate: Date,
        endDate: Date
    ) -> Observable<BossStoreFeedbackCursorResponse> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/store/\(storeId)/feedbacks/specific"
            let headers = HTTPUtils.jsonHeader()
            let paramerters: [String: Any] = [
                "startDate": DateUtils.toString(date: startDate, format: "yyyy-MM-dd"),
                "endDate": DateUtils.toString(date: endDate, format: "yyyy-MM-dd")
            ]
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                parameters: paramerters,
                headers: headers
            ).responseDecodable(
                of: ResponseContainer<BossStoreFeedbackCursorResponse>.self
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
