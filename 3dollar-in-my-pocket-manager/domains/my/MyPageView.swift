import UIKit

import RxSwift
import RxCocoa

final class MyPageView: BaseView {
    fileprivate let tapTabPublisher = PublishSubject<Int>()
    
    private let myStoreInfoButton = UIButton().then {
        $0.setTitle("my_page_store_info".localized, for: .normal)
        $0.setTitleColor(.gray30, for: .normal)
        $0.setTitleColor(.gray95, for: .selected)
        $0.titleLabel?.font = .extraBold(size: 18)
        $0.isSelected = true
    }
    
    private let statisticsButton = UIButton().then {
        $0.setTitle("my_pate_statistics".localized, for: .normal)
        $0.setTitleColor(.gray95, for: .normal)
        $0.setTitleColor(.gray30, for: .normal)
        $0.setTitleColor(.gray95, for: .selected)
        $0.titleLabel?.font = .extraBold(size: 18)
        $0.isSelected = false
    }
    
    let containerView = UIView()
    
    override func setup() {
        self.backgroundColor = .gray0
        self.addSubViews([
            self.myStoreInfoButton,
            self.statisticsButton,
            self.containerView
        ])
        self.myStoreInfoButton.rx.tap
            .do(onNext: { [weak self] in
                self?.myStoreInfoButton.isSelected = true
                self?.statisticsButton.isSelected = false
            })
            .map { _ in 0 }
            .bind(to: self.tapTabPublisher)
            .disposed(by: self.disposeBag)
        
        self.statisticsButton.rx.tap
            .do(onNext: { [weak self] in
                self?.myStoreInfoButton.isSelected = false
                self?.statisticsButton.isSelected = true
            })
            .map { _ in 1 }
            .bind(to: self.tapTabPublisher)
            .disposed(by: self.disposeBag)
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

extension Reactive where Base: MyPageView {
    var tapTab: ControlEvent<Int> {
        return ControlEvent(events: base.tapTabPublisher)
    }
}
