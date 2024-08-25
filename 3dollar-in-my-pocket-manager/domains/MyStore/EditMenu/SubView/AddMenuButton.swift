import UIKit
import Combine

final class AddMenuButton: BaseView {
    enum Layout {
        static let height: CGFloat = 48
    }
    
    var tapPublisher: AnyPublisher<Void, Never> {
        return addMenuButton.tapPublisher
    }
    
    let addMenuButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(
            "edit_menu_add".localized,
            attributes: AttributeContainer([
                .foregroundColor: UIColor.green,
                .font: UIFont.bold(size: 14) as Any
            ])
        )
        config.image = UIImage(named: "ic_add_menu")
        config.imagePadding = 8
        let button = UIButton(configuration: config)
        button.layer.borderColor = UIColor.green.cgColor
        button.layer.borderWidth = 1
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func setup() {
        addSubview(addMenuButton)
        addMenuButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(Layout.height)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }
}
