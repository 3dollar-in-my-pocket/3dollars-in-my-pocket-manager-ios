import Foundation

struct SignupRequest: Requestable {
    let bossName: String
    let businessNumber: String
    let certificationPhotoUrl: String
    let contactsNumber: String
    let socialType: SocialType
    let storeCategoriesIds: [String]
    let storeName: String
    let token: String
    
    var params: [String : Any] {
        [
            "bossName": bossName,
            "businessNumber": businessNumber,
            "certificationPhotoUrl": certificationPhotoUrl,
            "contactsNumber": contactsNumber,
            "socialType": socialType.rawValue,
            "storeCategoriesIds": storeCategoriesIds,
            "storeName": storeName,
            "token": token
        ]
    }
}
