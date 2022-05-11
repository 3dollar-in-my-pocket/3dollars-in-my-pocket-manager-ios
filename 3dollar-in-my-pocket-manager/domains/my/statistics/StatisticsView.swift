import UIKit

final class StatisticsView: BaseView {
    private let reviewCountLabel = ReviewCountLabel()
    
    private let filterButton = StatisticsFilterButton()
    
    override func setup() {
        self.backgroundColor = .gray0
        self.addSubViews([
            self.reviewCountLabel,
            self.filterButton
        ])
    }
    
    override func bindConstraints() {
        self.reviewCountLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(20)
        }
        
        self.filterButton.snp.makeConstraints { make in
            make.top.equalTo(self.reviewCountLabel.snp.bottom).offset(19)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }
    }
}
