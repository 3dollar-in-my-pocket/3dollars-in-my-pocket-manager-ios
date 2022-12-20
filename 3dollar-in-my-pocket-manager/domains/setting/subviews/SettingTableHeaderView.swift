import UIKit

import RxSwift
import RxCocoa

final class SettingTableHeaderView: BaseView {
    static let height: CGFloat = 90
    
    private let nameLabel = UILabel().then {
        $0.font = .bold(size: 24)
        $0.textColor = .white
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .regular(size: 24)
        $0.textColor = .white
        $0.text = "setting_name_description".localized
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.nameLabel,
            self.descriptionLabel
        ])
    }
    
    override func bindConstraints() {
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(16)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.nameLabel)
            make.right.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom)
        }
    }
    
    fileprivate func setName(name: String) {
        self.nameLabel.text = "\(name) 사장님"
    }
}

extension Reactive where Base: SettingTableHeaderView {
    var name: Binder<String> {
        return Binder(self.base) { view, name in
            view.setName(name: name)
        }
    }
}
