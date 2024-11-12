import Foundation

struct BossLogOutRequest: Encodable {
    let logoutDevice: BossLogOutDeviceRequest?
}

struct BossLogOutDeviceRequest: Encodable {
    let pushPlatform: String
    let pushToken: String
    
    init?(pushPlatform: String, pushToken: String?) {
        if let pushToken {
            self.pushPlatform = pushPlatform
            self.pushToken = pushToken
        } else {
            return nil
        }
    }
}
