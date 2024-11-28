import Alamofire

protocol SharedRepository {
    func createNonce(input: NonceCreateRequest) async -> ApiResult<NonceResponse>
}

final class SharedRepositoryImpl: SharedRepository {
    func createNonce(input: NonceCreateRequest) async -> ApiResult<NonceResponse> {
        return await SharedApi.nonce(input: input).asyncRequest()
    }
}
