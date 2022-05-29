import UIKit

import RxSwift
import RxCocoa

final class EditMenuView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 16)
        $0.textColor = .gray100
        $0.text = "edit_menu_title".localized
    }
    
    fileprivate let menuCountLabel = UILabel().then {
        $0.font = .medium(size: 14)
        $0.textColor = .black
    }
    
    let deleteButton = UIButton().then {
        $0.setTitle("edit_menu_delete".localized, for: .normal)
        $0.titleLabel?.font = .bold(size: 14)
        $0.setTitleColor(.red, for: .normal)
    }
    
    let menuTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.rowHeight = EditMenuTableViewCell.height
        $0.register(
            EditMenuTableViewCell.self,
            forCellReuseIdentifier: EditMenuTableViewCell.registerId
        )
    }
    
    let saveButton = UIButton().then {
        $0.setTitle("edit_menu_save".localized, for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.setTitleColor(UIColor(r: 251, g: 251, b: 251), for: .normal)
        $0.setBackgroundColor(color: .green, forState: .normal)
        $0.setBackgroundColor(color: .gray30, forState: .disabled)
    }
    
    let tableViewFooterView = EditMenuTableFooterView(
        frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 56)
    )
    
    override func setup() {
        self.backgroundColor = .gray0
        self.menuTableView.tableFooterView = self.tableViewFooterView
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.menuCountLabel,
            self.deleteButton,
            self.menuTableView,
            self.saveButton
        ])
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(25)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backButton)
        }
        
        self.menuCountLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.backButton.snp.bottom).offset(63)
        }
        
        self.deleteButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(self.menuCountLabel)
        }
        
        self.menuTableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.saveButton.snp.top)
            make.top.equalTo(self.menuCountLabel.snp.bottom).offset(16)
        }
        
        self.saveButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-64)
        }
    }
}


extension Reactive where Base: EditMenuView {
    var menuCount: Binder<Int> {
        return Binder(self.base) { view, count in
            view.menuCountLabel.text = "\(count)/20개의 메뉴가 등록되어 있습니다."
        }
    }
}
