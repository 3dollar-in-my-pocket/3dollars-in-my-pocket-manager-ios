import UIKit

final class MyPageView: BaseView {
    private let myStoreInfoButton = UIButton().then {
        $0.setTitle("가게정보", for: .normal)
        $0.setTitleColor(.gray95, for: .normal)
        $0.titleLabel?.font = .extraBold(size: 18)
    }
    
    private let statisticsButton = UIButton().then {
        $0.setTitle("통계", for: .normal)
        $0.setTitleColor(.gray95, for: .normal)
        $0.titleLabel?.font = .extraBold(size: 18)
    }
    
    let containerView = UIView()
    
    override func setup() {
        self.backgroundColor = .white
        self.addSubViews([
            self.myStoreInfoButton,
            self.statisticsButton,
            self.containerView
        ])
    }
    
    override func bindConstraints() {
        self.myStoreInfoButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(21)
        }
        
        self.statisticsButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.myStoreInfoButton)
            make.left.equalTo(self.myStoreInfoButton.snp.right).offset(22)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.myStoreInfoButton.snp.bottom).offset(16)
        }
    }
}
