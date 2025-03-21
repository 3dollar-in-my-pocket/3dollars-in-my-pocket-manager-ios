import Foundation

import Alamofire

protocol MessageRepository {
    func sendMessage(input: StoreMessageCreateRequest) async -> ApiResult<StoreMessageCreateResponse>
    
    func fetchMessages(storeId: String, cursor: String?) async -> ApiResult<StoreMessageListResponse>
}

final class MessageRepositoryImpl: MessageRepository {
    func sendMessage(input: StoreMessageCreateRequest) async -> ApiResult<StoreMessageCreateResponse> {
        return await MessageApi.sendMessage(input: input).asyncRequest()
    }
    
    func fetchMessages(storeId: String, cursor: String?) async -> ApiResult<StoreMessageListResponse> {
        return await MessageApi.fetchMessages(storeId: storeId, cursor: cursor).asyncRequest()
    }
}
