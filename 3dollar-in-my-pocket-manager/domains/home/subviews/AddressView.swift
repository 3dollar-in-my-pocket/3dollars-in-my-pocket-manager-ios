import UIKit

final class AddressView: BaseView {
    private let height:CGFloat = 56
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowOpacity = 0.08
    }
    
    private let addressLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .semiBold(size: 16)
        $0.text = "서울특별시 사직동"
        $0.textAlignment = .center
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.addressLabel
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(self.height)
        }
        
        self.addressLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.left.equalTo(self.containerView).offset(24)
            make.right.equalTo(self.containerView).offset(-24)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.containerView).priority(.high)
        }
    }
}
