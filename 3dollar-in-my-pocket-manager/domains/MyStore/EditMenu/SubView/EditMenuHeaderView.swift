import UIKit

final class EditMenuHeaderView: BaseView {
    enum Layout {
        static let height: CGFloat = 20
    }
    
    private let menuCountLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 14)
        label.textColor = .gray70
        return label
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("edit_menu_delete".localized, for: .normal)
        button.titleLabel?.font = .bold(size: 14)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    override func setup() {
        addSubview(menuCountLabel)
        menuCountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
        }
        
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalToSuperview()
        }
        
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }
    
    func setMenuCount(_ count: Int) {
        let text = "\(count)/20개의 메뉴가 등록되어 있습니다."
        let attributedTextRange = (text as NSString).range(of: "개의 메뉴가 등록되어 있습니다.")
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.gray30,
            range: attributedTextRange
        )
        
        menuCountLabel.attributedText = attributedString
    }
    
    func setDeleteMode(_ isDeleteMode: Bool) {
        let title = isDeleteMode ? "edit_menu_delete_all".localized : "edit_menu_delete".localized
        deleteButton.setTitle(title, for: .normal)
    }
}
