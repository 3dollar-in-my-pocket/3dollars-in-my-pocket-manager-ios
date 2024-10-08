import Foundation

import Alamofire

struct HTTPUtils {
    static let url = Bundle.apiURL
    
    static let defaultSession: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 4
        
        return Session(configuration: configuration)
    }()
    
    static let loginSession: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 6
        
        return Session(configuration: configuration)
    }()
    
    static let fileUploadSession: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        
        return Session(configuration: configuration)
    }()
    
    static func jsonHeader() -> HTTPHeaders {
        var headers = ["Accept": "application/json"] as HTTPHeaders
        
        headers.add(self.defaultUserAgent)
        return headers
    }
    
    static func defaultHeader() -> HTTPHeaders {
        var headers = HTTPHeaders()
        headers.add(self.defaultUserAgent)
        
        if !Preference.shared.userToken.isEmpty {
            headers.add(HTTPHeader(name: "Authorization", value: "Bearer " + Preference.shared.userToken))
        }

        return headers
    }
    
    static func jsonWithTokenHeader() -> HTTPHeaders {
        var headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer " + Preference.shared.userToken
        ] as HTTPHeaders
        
        headers.add(self.defaultUserAgent)
        return headers
    }
    
    static let defaultUserAgent: HTTPHeader = {
        let info = Bundle.main.infoDictionary
        let executable = (info?[kCFBundleExecutableKey as String] as? String) ??
        (ProcessInfo.processInfo.arguments.first?.split(separator: "/").last.map(String.init)) ??
        "Unknown"
        let bundle = info?[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
        let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = info?[kCFBundleVersionKey as String] as? String ?? "Unknown"
        
        let osNameVersion: String = {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            let osName: String = "iOS"
            
            return "\(osName) \(versionString)"
        }()
        
        let userAgent = "\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion))"
        
        return .userAgent(userAgent)
    }()
}
