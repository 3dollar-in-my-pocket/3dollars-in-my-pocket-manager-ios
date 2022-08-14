import UIKit

import Base
import RxSwift
import RxCocoa

final class ReviewCountLabel: BaseView {
    private let totalLabel = UILabel().then {
        $0.font = .bold(size: 24)
        $0.textColor = .gray95
        $0.text = "총"
    }
    
    fileprivate let countLabel = PaddingLabel(
        topInset: 4,
        bottomInset: 4,
        leftInset: 8,
        rightInset: 8
    ).then {
        $0.font = .extraBold(size: 18)
        $0.textColor = .green
        $0.backgroundColor = UIColor(r: 225, g: 243, b: 234)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private let ofLabel = UILabel().then {
        $0.font = .bold(size: 24)
        $0.textColor = .gray95
        $0.text = "의"
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .bold(size: 24)
        $0.textColor = .gray95
        $0.text = "statistics_review_count".localized
    }
    
    override func setup() {
        self.addSubViews([
            self.totalLabel,
            self.countLabel,
            self.ofLabel,
            self.descriptionLabel
        ])
    }
    
    override func bindConstraints() {
        self.totalLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.countLabel.snp.makeConstraints { make in
            make.left.equalTo(self.totalLabel.snp.right).offset(6)
            make.centerY.equalTo(self.countLabel)
            make.height.equalTo(28)
        }
        
        self.ofLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.countLabel)
            make.left.equalTo(self.countLabel.snp.right).offset(4)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.totalLabel)
            make.top.equalTo(self.totalLabel.snp.bottom).offset(4)
        }
        
        self.snp.makeConstraints { make in
            make.left.equalTo(self.totalLabel).priority(.high)
            make.top.equalTo(self.totalLabel).priority(.high)
            make.right.equalTo(self.descriptionLabel).priority(.high)
            make.bottom.equalTo(self.descriptionLabel).priority(.high)
        }
    }
}

extension Reactive where Base: ReviewCountLabel {
    var reviewCount: Binder<Int> {
        return Binder(self.base) { view, reviewCount in
            view.countLabel.text = "\(reviewCount)개"
        }
    }
}
