import UIKit

extension UIFont {
    static func light(size: CGFloat) -> UIFont? {
        return Self.init(name: "AppleSDGothicNeo-Light", size: size)
    }
    
    static func semiBold(size: CGFloat) -> UIFont? {
        return Self.init(name: "AppleSDGothicNeo-SemiBold", size: size)
    }
    
    static func bold(size: CGFloat) -> UIFont? {
        return Self.init(name: "AppleSDGothicNeo-Bold", size: size)
    }
    
    static func regular(size: CGFloat) -> UIFont? {
        return Self.init(name: "AppleSDGothicNeo-Regular", size: size)
    }
    
    static func medium(size: CGFloat) -> UIFont? {
        return Self.init(name: "AppleSDGothicNeo-Medium", size: size)
    }
    
    static func extraBold(size: CGFloat) -> UIFont? {
        return Self.init(name: "AppleSDGothicNeoEB00", size: size)
    }
}
