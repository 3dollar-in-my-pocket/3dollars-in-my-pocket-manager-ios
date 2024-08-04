import UIKit

final class ShowOtherButton: BaseView {
    let tapGesture = UITapGestureRecognizer()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .white
        return view
    }()
    
    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_check_off")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 14)
        label.textColor = .gray100
        label.text = "home_show_other".localized
        label.setKern(kern: -0.4)
        return label
    }()
    
    override func setup() {
        super.setup()
        
        addGestureRecognizer(tapGesture)
        
        addSubViews([
            backgroundView,
            checkImageView,
            titleLabel
        ])
        
        backgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalTo(titleLabel).offset(11)
            make.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        
        checkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.left.equalTo(backgroundView).offset(12)
            make.centerY.equalTo(backgroundView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(checkImageView.snp.right).offset(8)
            make.centerY.equalTo(backgroundView)
        }
        
        snp.makeConstraints { make in
            make.edges.equalTo(backgroundView).priority(.high)
        }
    }
    
    func bind(_ showOtherStore: Bool) {
        checkImageView.image = showOtherStore ? UIImage(named: "ic_check") : UIImage(named: "ic_check_off")
    }
}
