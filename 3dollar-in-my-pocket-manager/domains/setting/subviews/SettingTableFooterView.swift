import UIKit

import Base

final class SettingTableFooterView: BaseView {
    static let height: CGFloat = 40
    
    private let alertImage = UIImageView().then {
        $0.image = UIImage(named: "ic_alert")
    }
    
    let signoutButton = UIButton().then {
        $0.setTitle("setting_signout".localized, for: .normal)
        $0.titleLabel?.font = .medium(size: 14)
        $0.setTitleColor(.gray40, for: .normal)
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.alertImage,
            self.signoutButton
        ])
    }
    
    override func bindConstraints() {
        self.alertImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(24)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        self.signoutButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.alertImage)
            make.left.equalTo(self.alertImage.snp.right).offset(8)
        }
    }
}
