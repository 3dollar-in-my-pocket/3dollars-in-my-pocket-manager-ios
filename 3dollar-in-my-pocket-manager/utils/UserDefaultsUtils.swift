import Foundation

struct UserDefaultsUtils {
    private let KEY_TOKEN = "KEY_TOKEN"
    private let KEY_USER_ID = "KEY_USER_ID"
    
    let instance: UserDefaults
    
    init(name: String? = nil) {
        if let name = name {
            UserDefaults().removePersistentDomain(forName: name)
            instance = UserDefaults(suiteName: name)!
        } else {
            instance = UserDefaults.standard
        }
    }
    
    func setUserToken(token: String) {
        self.instance.set(token, forKey: UserDefaultsUtil.KEY_TOKEN)
    }
    
    func getUserToken() -> String {
        return self.instance.string(forKey: UserDefaultsUtil.KEY_TOKEN) ?? ""
    }
    
    func setUserId(id: Int) {
        self.instance.set(id, forKey: UserDefaultsUtil.KEY_USER_ID)
    }
    
    func getUserId() -> Int {
        return self.instance.integer(forKey: UserDefaultsUtil.KEY_USER_ID)
    }
}
