import UIKit

final class SignupView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "signup_title".localized
        $0.font = .semiBold(size: 16)
        $0.textColor = .gray100
    }
    
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .clear
    }
    
    private let containerView = UIView()
    
    private let descriptionLabel = UILabel().then {
        $0.font = .bold(size: 24)
        $0.textColor = .gray95
        $0.text = "signup_description".localized
        $0.setLineHeight(lineHeight: 31)
    }
    
    private let roundedBackgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.shadowColor = UIColor(r: 0, g: 198, b: 103).cgColor
        $0.layer.shadowOpacity = 0.04
    }
    
}
