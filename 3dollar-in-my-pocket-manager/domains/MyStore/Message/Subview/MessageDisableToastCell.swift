import UIKit

final class MessageDisableToastCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 44
    }
    
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .gray90
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
}
