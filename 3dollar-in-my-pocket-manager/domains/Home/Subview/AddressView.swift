import UIKit

final class AddressView: BaseView {
    enum Layout {
        static let height:CGFloat = 56
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowOpacity = 0.08
        return view
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .semiBold(size: 16)
        label.textAlignment = .center
        return label
    }()
    
    override func setup() {
        super.setup()
        
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(Layout.height)
        }
        
        addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.centerY.equalTo(containerView)
            make.left.equalTo(containerView).offset(24)
            make.right.equalTo(containerView).offset(-24)
        }
        
        snp.makeConstraints { make in
            make.edges.equalTo(containerView).priority(.high)
        }
    }
    
    func bind(_ address: String) {
        addressLabel.text = address
    }
}
