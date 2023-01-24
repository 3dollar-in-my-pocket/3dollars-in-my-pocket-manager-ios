import Foundation

import RxSwift
import Alamofire

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
            )
            .responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(
                        type: [BossStoreFeedbackTypeResponse].self,
                        response: response
                    )
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
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
            )
            .responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(
                        type: [BossStoreFeedbackCountResponse].self,
                        response: response
                    )
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
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
            ).responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(
                        type: BossStoreFeedbackCursorResponse.self,
                        response: response
                    )
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
}
