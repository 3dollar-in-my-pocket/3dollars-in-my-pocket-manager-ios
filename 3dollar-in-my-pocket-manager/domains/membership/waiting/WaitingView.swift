import UIKit

final class WaitingView: BaseView {
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 30)
        $0.textColor = .gray80
        $0.text = "waiting_title".localized
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = .gray50
        $0.text = "waiting_description".localized
        $0.numberOfLines = 0
    }
    
    let questionButton = UIButton().then {
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .bold(size: 16)
        $0.setTitle("waiting_question_button".localized, for: .normal)
        $0.backgroundColor = .green
        $0.layer.cornerRadius = 8
    }
    
    override func setup() {
        self.backgroundColor = .white
        self.addSubViews([
            self.titleLabel,
            self.descriptionLabel,
            self.questionButton
        ])
    }
    
    override func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(44)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
        }
        
        self.questionButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-50)
            make.height.equalTo(48)
        }
    }
}
