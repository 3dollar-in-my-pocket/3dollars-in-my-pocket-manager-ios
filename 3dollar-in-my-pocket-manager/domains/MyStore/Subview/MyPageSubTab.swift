import UIKit
import RxCocoa
import RxSwift

final class MyPageSubTab: BaseView {
    private let newImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "img_new")
        
        return imageView
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.gray30, for: .normal)
        button.setTitleColor(.gray95, for: .selected)
        button.titleLabel?.font = .extraBold(size: 18)
        
        return button
    }()
    
    var isSelected: Bool {
        didSet {
            button.isSelected = isSelected
        }
    }
    
    var isNew: Bool = false {
        didSet {
            newImage.isHidden = isNew.isNot
        }
    }
    
    init(title: String, isSelected: Bool) {
        self.isSelected = isSelected
        super.init(frame: .zero)
        
        button.setTitle(title, for: .normal)
        button.isSelected = isSelected
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        addSubview(button)
        button.snp.makeConstraints {
            $0.height.equalTo(23)
        }
        
        addSubview(newImage)
        newImage.snp.makeConstraints {
            $0.leading.equalTo(button.snp.trailing).offset(-9)
            $0.bottom.equalTo(button.snp.top).offset(4)
            $0.width.equalTo(35)
            $0.height.equalTo(16)
        }
        
        snp.makeConstraints {
            $0.leading.top.bottom.equalTo(button)
            $0.trailing.equalTo(newImage)
        }
    }
}

extension Reactive where Base: MyPageSubTab {
    var tap: ControlEvent<Void> {
        return base.button.rx.tap
    }
}
