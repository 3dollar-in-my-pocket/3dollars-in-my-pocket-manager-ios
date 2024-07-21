import Foundation

struct UserDefaultsUtils {
    private let KEY_TOKEN = "KEY_TOKEN"
    private let KEY_USER_ID = "KEY_USER_ID"
    private let KEY_STORE_ID = "KEY_STORE_ID"
    private let KEY_SHOWN_STORE_NOTICE_NEW_BADGE = "KEY_SHOWN_STORE_NOTICE_NEW_BADGE"
    
    let instance: UserDefaults
    
    init(name: String? = nil) {
        if let name = name {
            UserDefaults().removePersistentDomain(forName: name)
            instance = UserDefaults(suiteName: name)!
        } else {
            instance = UserDefaults.standard
        }
    }
    
    var userToken: String {
        set {
            self.instance.set(newValue, forKey: self.KEY_TOKEN)
        }
        get {
            return self.instance.string(forKey: self.KEY_TOKEN) ?? ""
        }
    }
    
    var userId: String {
        set {
            self.instance.set(newValue, forKey: self.KEY_USER_ID)
        }
        get {
            return self.instance.string(forKey: self.KEY_USER_ID) ?? ""
        }
    }
    
    var storeId: String {
        set {
            self.instance.set(newValue, forKey: self.KEY_STORE_ID)
        }
        get {
            return self.instance.string(forKey: self.KEY_STORE_ID) ?? ""
        }
    }
    
    var shownStoreNoticeNewBadge: Bool {
        set {
            instance.set(newValue, forKey: KEY_SHOWN_STORE_NOTICE_NEW_BADGE)
        }
        get {
            return instance.bool(forKey: KEY_SHOWN_STORE_NOTICE_NEW_BADGE)
        }
    }
    
    func clear() {
        self.instance.removeObject(forKey: self.KEY_TOKEN)
        self.instance.removeObject(forKey: self.KEY_USER_ID)
        self.instance.removeObject(forKey: self.KEY_STORE_ID)
        instance.removeObject(forKey: KEY_SHOWN_STORE_NOTICE_NEW_BADGE)
    }
}
