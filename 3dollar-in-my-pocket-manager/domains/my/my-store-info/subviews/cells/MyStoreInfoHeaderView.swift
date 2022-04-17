import UIKit

final class MyStoreInfoHeaderView: UICollectionReusableView {
    static let registerId = "\(MyStoreInfoHeaderView.self)"
    static let height: CGFloat = 69
    
    private let titleLabel = UILabel().then {
        $0.font = .extraBold(size: 18)
        $0.textColor = .gray95
        $0.text = "사장님 한마디"
    }
    
    fileprivate let rightButton = UIButton().then {
        $0.setTitleColor(.green, for: .normal)
        $0.setTitle("정보 수정", for: .normal)
        $0.titleLabel?.font = .bold(size: 12)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.addSubViews([
            self.titleLabel,
            self.rightButton
        ])
    }
    
    private func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(37)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        self.rightButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(self.titleLabel)
        }
    }
}
