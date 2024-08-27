import Foundation

import RxSwift
import Alamofire

protocol FeedbackServiceType {
    func fetchFeedbackTypes() -> Observable<[FeedbackTypeResponse]>
    
    func fetchTotalStatistics(storeId: String) -> Observable<[FeedbackCountWithRatioResponse]>
    
    func fetchDailyStatistics(
        storeId: String,
        startDate: Date,
        endDate: Date
    ) -> Observable<ContentListWithCursor<FeedbackGroupingDateResponse>>
}

struct FeedbackService: FeedbackServiceType {
    func fetchFeedbackTypes() -> Observable<[FeedbackTypeResponse]> {
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
                        type: [FeedbackTypeResponse].self,
                        response: response
                    )
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
    
    func fetchTotalStatistics(storeId: String) -> Observable<[FeedbackCountWithRatioResponse]> {
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
                        type: [FeedbackCountWithRatioResponse].self,
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
    ) -> Observable<ContentListWithCursor<FeedbackGroupingDateResponse>> {
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
                        type: ContentListWithCursor<FeedbackGroupingDateResponse>.self,
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
