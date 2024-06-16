import Foundation
import Alamofire

protocol StorePostRepository {
    func fetchPostList(storeId: String, cursor: String?) async -> ApiResult<StorePostListApiResponse>
}


final class StorePostRepositoryImpl: StorePostRepository {
    func fetchPostList(storeId: String, cursor: String?) async -> ApiResult<StorePostListApiResponse> {
        return await StorePostApi.fetchPostList(storeId: storeId, size: 20, cursor: cursor).asyncRequest()
    }
}
