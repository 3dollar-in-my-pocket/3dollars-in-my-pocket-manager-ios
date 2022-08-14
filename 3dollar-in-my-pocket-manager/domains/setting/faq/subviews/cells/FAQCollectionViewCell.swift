import UIKit

import Base

final class FAQCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(FAQCollectionViewCell.self)"
    static let height: CGFloat = 149
    
    private let containerView = UIView().then {
        $0.backgroundColor = .gray95
        $0.layer.cornerRadius = 16
    }
    
    private let questionMarkLabel = UILabel().then {
        $0.textColor = .green
        $0.font = .bold(size: 14)
        $0.numberOfLines = 0
        $0.text = "Q"
    }
    
    private let questionLabel = UILabel().then {
        $0.textColor = .green
        $0.font = .bold(size: 14)
        $0.numberOfLines = 0
    }
    
    private let answerLabel = UILabel().then {
        $0.textColor = .gray6
        $0.font = .bold(size: 14)
        $0.numberOfLines = 0
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.containerView,
            self.questionMarkLabel,
            self.questionLabel,
            self.answerLabel
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
            make.bottom.equalTo(self.answerLabel).offset(16).priority(.high)
        }
        
        self.questionMarkLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.top.equalTo(self.containerView).offset(16)
            make.width.equalTo(12)
        }
        
        self.questionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.questionMarkLabel.snp.right).offset(8)
            make.top.equalTo(self.questionMarkLabel)
            make.right.equalTo(self.containerView).offset(-20)
        }
        
        self.answerLabel.snp.makeConstraints { make in
            make.left.equalTo(self.questionLabel)
            make.right.equalTo(self.questionLabel)
            make.top.equalTo(self.questionLabel.snp.bottom).offset(12)
        }
    }
    
    func bind(faq: FAQ) {
        self.questionLabel.text = faq.question
        self.answerLabel.text = faq.answer
    }
}
