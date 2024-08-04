import Foundation

import RxSwift
import Alamofire

protocol BankServiceType {
    func fetchBankList() -> Observable<[BankResponse]>
}

final class BankService: BankServiceType {
    func fetchBankList() -> Observable<[BankResponse]> {
        let observable: Observable<EnumResponse> = .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/enums"
            let headers = HTTPUtils.jsonHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: headers
            ).responseData { response in
                if response.isSuccess() {
                    observer.processValue(type: EnumResponse.self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            }
            
            return Disposables.create()
        }
        
        
        return observable.map { $0.Bank }
    }
}
