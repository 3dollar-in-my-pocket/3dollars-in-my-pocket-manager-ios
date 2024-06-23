import Foundation
import Alamofire

protocol StorePostRepository {
    func fetchPostList(storeId: String, cursor: String?) async -> ApiResult<StorePostListApiResponse>
    
    func uploadPost(storeId: String, input: PostCreateApiRequest) async -> ApiResult<PostCreateApiResponse>
}


final class StorePostRepositoryImpl: StorePostRepository {
    func fetchPostList(storeId: String, cursor: String?) async -> ApiResult<StorePostListApiResponse> {
        return await StorePostApi.fetchPostList(storeId: storeId, size: 20, cursor: cursor).asyncRequest()
    }
    
    func uploadPost(storeId: String, input: PostCreateApiRequest) async -> ApiResult<PostCreateApiResponse> {
        return await StorePostApi.uploadPost(storeId: storeId, input: input).asyncRequest()
    }
}
