import Foundation

final class Preference {
    static let shared = Preference()
    
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
            instance.set(newValue, forKey: "KEY_TOKEN")
        }
        get {
            return instance.string(forKey: "KEY_TOKEN") ?? ""
        }
    }
    
    var userId: String {
        set {
            instance.set(newValue, forKey: "KEY_USER_ID")
        }
        get {
            return instance.string(forKey: "KEY_USER_ID") ?? ""
        }
    }
    
    var storeId: String {
        set {
            instance.set(newValue, forKey: "KEY_STORE_ID")
        }
        get {
            return instance.string(forKey: "KEY_STORE_ID") ?? ""
        }
    }
    
    var storeName: String {
        set {
            instance.set(newValue, forKey: "KEY_STORE_NAME")
        }
        get {
            return instance.string(forKey: "KEY_STORE_NAME") ?? ""
        }
    }
    
    var shownMessageNewBadge: Bool {
        set {
            instance.set(newValue, forKey: "KEY_SHOWN_MESSAGE_NEW_BADGE")
        }
        get {
            return instance.bool(forKey: "KEY_SHOWN_MESSAGE_NEW_BADGE")
        }
    }
    
    var fcmToken: String? {
        set {
            instance.set(newValue, forKey: "KEY_FCM_TOKEN")
        }
        get {
            return instance.string(forKey: "KEY_FCM_TOKEN")
        }
    }
    
    var shownMessageTooltip: Bool {
        set {
            instance.set(newValue, forKey: "KEY_SHOWN_MESSAGE_TOOLTIP")
        }
        get {
            return instance.bool(forKey: "KEY_SHOWN_MESSAGE_TOOLTIP")
        }
    }
    
    var shownMyPageMessageTooltip: Bool {
        set {
            instance.set(newValue, forKey: "KEY_SHOWN_MYPAGE_MESSAGE_TOOLTIP")
        }
        get {
            return instance.bool(forKey: "KEY_SHOWN_MYPAGE_MESSAGE_TOOLTIP")
        }
    }
    
    func clear() {
        instance.removeObject(forKey: "KEY_TOKEN")
        instance.removeObject(forKey: "KEY_USER_ID")
        instance.removeObject(forKey: "KEY_STORE_ID")
        instance.removeObject(forKey: "KEY_SHOWN_STORE_NOTICE_NEW_BADGE")
        instance.removeObject(forKey: "KEY_STORE_NAME")
        instance.removeObject(forKey: "KEY_SHOWN_MESSAGE_TOOLTIP")
        instance.removeObject(forKey: "KEY_SHOWN_MYPAGE_MESSAGE_TOOLTIP")
    }
}
