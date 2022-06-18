import Foundation

extension Bundle {
    static var apiURL: String {
        guard let apiURL = Bundle.main.infoDictionary?["API_URL"] as? String else {
            fatalError("API_URL이 정의되지 않았습니다.")
        }
        
        return apiURL
    }
    
    static var kakaoAppKey: String {
        guard let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_APP_KEY"] as? String else {
            fatalError("KAKAO_APP_KEY가 정의되지 않았습니다.")
        }
        
        return kakaoAppKey
    }
    
    static var kakaoChannelUrl: String {
        guard let kakaoChannelUrl = Bundle.main.infoDictionary?["KAKAO_CHANNEL_URL"] as? String else {
            fatalError("KAKAO_CHANNEL_URL가 정의되지 않았습니다.")
        }
        
        return kakaoChannelUrl
    }
}
