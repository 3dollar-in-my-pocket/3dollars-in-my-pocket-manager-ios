import Foundation
import Alamofire

protocol StorePostRepository {
    func fetchPostList(storeId: String, cursor: String?) async -> ApiResult<StorePostListApiResponse>
    
    func uploadPost(storeId: String, input: PostCreateApiRequest) async -> ApiResult<PostCreateApiResponse>
    
    func deletePost(storeId: String, postId: String) async -> ApiResult<String>
    
    func editPost(storeId: String, postId: String, input: PostCreateApiRequest) async -> ApiResult<StorePostApiResponse>
}


final class StorePostRepositoryImpl: StorePostRepository {
    func fetchPostList(storeId: String, cursor: String?) async -> ApiResult<StorePostListApiResponse> {
        return await StorePostApi.fetchPostList(storeId: storeId, size: 50, cursor: cursor).asyncRequest()
    }
    
    func uploadPost(storeId: String, input: PostCreateApiRequest) async -> ApiResult<PostCreateApiResponse> {
        return await StorePostApi.uploadPost(storeId: storeId, input: input).asyncRequest()
    }
    
    func deletePost(storeId: String, postId: String) async -> ApiResult<String> {
        return await StorePostApi.deletePost(storeId: storeId, postId: postId).asyncRequest()
    }
    
    func editPost(storeId: String, postId: String, input: PostCreateApiRequest) async -> ApiResult<StorePostApiResponse> {
        return await StorePostApi.editPost(storeId: storeId, postId: postId, input: input).asyncRequest()
    }
}
