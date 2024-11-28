import UIKit
import Combine

final class MyPageSubTab: BaseView {
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
    
    var tapPublisher: AnyPublisher<Void, Never> {
        button.tapPublisher
    }
    
    private let newImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Assets.imgNew.image
        imageView.isHidden = true
        return imageView
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.gray30, for: .normal)
        button.setTitleColor(.gray95, for: .selected)
        button.titleLabel?.font = .extraBold(size: 18)
        
        return button
    }()
    
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
            $0.edges.equalTo(button)
        }
    }
}
