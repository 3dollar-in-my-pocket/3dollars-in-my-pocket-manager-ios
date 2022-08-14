import UIKit

import Base

final class EditMenuTableFooterView: BaseView {
    let addMenuButton = UIButton().then {
        $0.layer.borderColor = UIColor.green.cgColor
        $0.layer.borderWidth = 1
        $0.setImage(UIImage(named: "ic_add_menu"), for: .normal)
        $0.setTitle("edit_menu_add".localized, for: .normal)
        $0.setTitleColor(.green, for: .normal)
        $0.titleLabel?.font = .bold(size: 14)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 8)
    }
    
    override func setup() {
        self.addSubViews([
            self.addMenuButton
        ])
    }
    
    override func bindConstraints() {
        self.addMenuButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24).priority(.high)
            make.top.equalToSuperview().offset(24).priority(.high)
            make.right.equalToSuperview().offset(-24).priority(.high)
            make.height.equalTo(48)
        }
    }
}
