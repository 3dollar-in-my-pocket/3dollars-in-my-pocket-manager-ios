import Alamofire
import RxSwift

protocol CategoryServiceType {
    func fetchCategories() -> Observable<[StoreCategoryResponse]>
}

struct CategoryService: CategoryServiceType {
    func fetchCategories() -> Observable<[StoreCategoryResponse]> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/store/categories"
            let headers = HTTPUtils.jsonHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: headers
            ).responseDecodable(of: ResponseContainer<[StoreCategoryResponse]>.self) { response in
                if response.isSuccess() {
                    observer.processValue(response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
}
