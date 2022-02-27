import Foundation

extension Bundle {
    static var apiURL: String {
        guard let apiURL = Bundle.main.infoDictionary?["API_URL"] as? String else {
            fatalError("API_URL이 정의되지 않았습니다.")
        }
        
        return apiURL
    }
}
