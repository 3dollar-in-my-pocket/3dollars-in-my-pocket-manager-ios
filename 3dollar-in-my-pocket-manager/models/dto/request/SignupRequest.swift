import Foundation

struct SignupRequest: Requestable {
    let bossName: String
    let businessNumber: String
    let certificationPhotoUrl: String
    let socialType: SocialType
    let storeCategoriesIds: [String]
    let storeName: String
    let token: String
    
    var params: [String : Any] {
        [
            "bossName": bossName,
            "businessNumber": businessNumber,
            "certificationPhotoUrl": certificationPhotoUrl,
            "socialType": socialType.rawValue,
            "storeCategoriesIds": storeCategoriesIds,
            "storeName": storeName,
            "token": token
        ]
    }
}
