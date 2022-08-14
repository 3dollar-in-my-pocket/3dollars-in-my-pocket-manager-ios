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
            )
            .responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(type: [StoreCategoryResponse].self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
}
