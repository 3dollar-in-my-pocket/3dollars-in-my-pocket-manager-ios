import Foundation

import RxSwift
import Alamofire

protocol FAQServiceType {
    func fetchFAQs() -> Observable<[FAQResponse]>
}

struct FAQService: FAQServiceType {
    func fetchFAQs() -> Observable<[FAQResponse]> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/faqs"
            let headers = HTTPUtils.jsonHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: headers
            ).responseData { response in
                if response.isSuccess() {
                    observer.processValue(type: [FAQResponse].self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
}
