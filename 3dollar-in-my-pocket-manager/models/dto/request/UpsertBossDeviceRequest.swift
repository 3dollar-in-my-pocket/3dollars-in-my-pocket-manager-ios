import Foundation

struct UpsertBossDeviceRequest: Encodable {
    let pushPlatformType: String
    let pushToken: String
    
    enum CodingKeys: String, CodingKey {
        case pushPlatformType
        case pushToken
    }
    
    init(pushToken: String) {
        self.pushPlatformType = "FCM"
        self.pushToken = pushToken
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.pushPlatformType, forKey: .pushPlatformType)
        try container.encode(self.pushToken, forKey: .pushToken)
    }
}
