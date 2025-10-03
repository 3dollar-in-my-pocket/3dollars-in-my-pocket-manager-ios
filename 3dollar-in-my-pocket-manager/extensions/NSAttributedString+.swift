import Foundation

extension NSAttributedString {
    func size(_ size: CGSize) -> CGSize {
        boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).size
    }
    
    func height(width: CGFloat) -> CGFloat {
        size(CGSize(width: width, height: .greatestFiniteMagnitude)).height
    }
    
    func width(height: CGFloat) -> CGFloat {
        size(CGSize(width: .greatestFiniteMagnitude, height: height)).width
    }
    
    func size(maxWidth: CGFloat) -> CGSize {
        let constrainedSize = size(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        let actualWidth = width(height: .greatestFiniteMagnitude) + 3
        
        return CGSize(width: min(actualWidth, maxWidth), height: constrainedSize.height)
    }
}
