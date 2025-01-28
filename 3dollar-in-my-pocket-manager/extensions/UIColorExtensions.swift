import UIKit

extension UIColor {
    /// r: 250, g: 250, b: 250
    static let gray0 = UIColor(r: 250, g: 250, b: 250)
    
    /// r: 244, g: 244, b: 244
    static let gray5 = UIColor(r: 244, g: 244, b: 244)
    
    /// r:242, g: 242, b: 242
    static let gray6 = UIColor(r: 242, g: 242, b: 242)
    
    /// r: 226, g: 226, b: 226
    static let gray10 = UIColor(r: 226, g: 226, b: 226)
    
    /// r: 208 g: 208 b: 208
    static let gray20 = UIColor(r: 208, g: 208, b: 208)
    
    /// r: 183, g: 183, b: 183
    static let gray30 = UIColor(r: 183, g: 183, b: 183)
    
    /// r: 150, g: 150, b: 150
    static let gray40 = UIColor(r: 150, g: 150, b: 150)
    
    /// r: 120, g: 120, b: 120
    static let gray50 = UIColor(r: 120, g: 120, b: 120)
    
    /// r: 120, g: 120, b: 120
    static let gray60 = UIColor(r: 120, g: 120, b: 120)
    
    /// r: 70, g: 70, b: 70
    static let gray70 = UIColor(r: 70, g: 70, b: 70)
    
    /// r: 50 g: 50, b: 50
    static let gray80 = UIColor(r: 50, g: 50, b: 50)
    
    /// r: 35 g: 35, b: 35
    static let gray90 = UIColor(r: 35, g: 35, b: 35)
    
    /// r: 26, g: 26, b: 26
    static let gray95 = UIColor(r: 26, g: 26, b: 26)
    
    /// r: 15, g: 15, b: 15
    static let gray100 = UIColor(r: 15, g: 15, b: 15)
    
    /// r: 255, g: 161, b: 170
    static let pink = UIColor(r: 255, g: 161, b: 170)
    
    /// r: 255, g: 243, b: 244
    static let pink100 = UIColor(r: 255, g: 243, b: 244)
    
    /// r: 255 g: 218 b: 221
    static let pink200 = UIColor(r: 255, g: 218, b: 221)
    
    /// r: 0, g: 198, b: 103
    static let green = UIColor(r: 0, g: 198, b: 103)
    
    /// r: 241, g: 255, b: 248
    static let green100 = UIColor(r: 241, g: 255, b: 248)
    
    /// r:255 g: 92, b: 67
    static let red = UIColor(r: 255, g: 92, b: 67)
    
    /// r:5, g: 5, b: 5
    static let black = UIColor(r: 5, g: 5, b: 5)
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
    convenience init?(hex: String) {
        let red, green, blue, alpha: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                if hexColor.count == 8 {
                    red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    alpha = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: red, green: green, blue: blue, alpha: alpha)
                    return
                }
                
                if hexColor.count == 6 {
                    red   = CGFloat((hexNumber & 0xff0000) >> 16) / 255.0
                    green = CGFloat((hexNumber & 0x00ff00) >> 8) / 255.0
                    blue  = CGFloat(hexNumber & 0x0000ff) / 255.0
                    
                    self.init(red: red, green: green, blue: blue, alpha: 1)
                    return
                }
            }
        }
        return nil
    }
}
