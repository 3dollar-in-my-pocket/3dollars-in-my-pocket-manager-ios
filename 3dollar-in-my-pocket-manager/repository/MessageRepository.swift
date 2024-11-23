import Foundation

import Alamofire

protocol MessageRepository {
    func sendMessage(input: StoreMessageCreateRequest) async -> ApiResult<StoreMessageResponse>
}

final class MessageRepositoryImpl: MessageRepository {
    func sendMessage(input: StoreMessageCreateRequest) async -> ApiResult<StoreMessageResponse> {
        return await MessageApi.sendMessage(input: input).asyncRequest()
    }
}
