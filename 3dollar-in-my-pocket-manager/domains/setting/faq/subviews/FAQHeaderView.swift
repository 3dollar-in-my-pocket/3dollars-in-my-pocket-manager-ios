import UIKit

import RxSwift

final class FAQHeaderView: UICollectionReusableView {
    static let registerId = "\(FAQHeaderView.self)"
    static let height: CGFloat = 63
    
    var disposeBag = DisposeBag()
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 16)
        $0.textColor = .white
    }
    
    private let strokeView = UIView().then {
        $0.backgroundColor = .green
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(title: String) {
        self.titleLabel.text = title
    }
    
    private func setup() {
        self.addSubViews([
            self.strokeView,
            self.titleLabel
        ])
    }
    
    private func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(28)
        }
        
        self.strokeView.snp.makeConstraints { make in
            make.bottom.equalTo(self.titleLabel)
            make.left.equalTo(self.titleLabel)
            make.right.equalTo(self.titleLabel).offset(1)
            make.height.equalTo(8)
        }
    }
}
