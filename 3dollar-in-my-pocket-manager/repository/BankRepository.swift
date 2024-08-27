import Foundation

import RxSwift
import Alamofire

protocol BankRepository {
    func fetchBankList() async -> ApiResult<[BossBank]>
}

final class BankRepositoryImpl: BankRepository {
    func fetchBankList() async -> ApiResult<[BossBank]> {
        let result: ApiResult<EnumResponse> = await BankApi.fetchBankList.asyncRequest()
        return result.map { $0.Bank }
    }
}
