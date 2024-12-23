import UIKit

final class WaitingView: BaseView {
    private let gradient = CAGradientLayer()
    
    private let scrollView = UIScrollView().then {
        $0.contentInset = .init(top: 0, left: 0, bottom: 100, right: 0)
        $0.showsVerticalScrollIndicator = false
    }
    
    private let scrollViewContainerView = UIView()
    
    private let topContainerView = UIView().then {
        $0.backgroundColor = .gray95
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 30)
        $0.textColor = .white
        $0.text = "waiting_title".localized
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = .gray50
        $0.numberOfLines = 0
        $0.textAlignment = .center
        
        let text = "waiting_description".localized
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.green,
            range: (text as NSString).range(of: "주말을 제외한 평일 기준 약 2-5일")
        )
        
        $0.attributedText = attributedString
    }
    
    private let bottomContainerView = UIView().then {
        $0.layer.cornerRadius = 24
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.backgroundColor = .gray90
    }
    
    private let bottomContainerTitleLabel1 = UILabel().then {
        $0.font = .semiBold(size: 18)
        $0.textColor = .white
        $0.text = "waiting_bottom_description_1".localized
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let bottomContainerImage1 = UIImageView().then {
        $0.image = UIImage(named: "img_waiting_bottom_1")
        $0.contentMode = .scaleAspectFill
    }
    
    private let bottomContainerImage2 = UIImageView().then {
        $0.image = UIImage(named: "img_waiting_bottom_2")
        $0.contentMode = .scaleAspectFill
    }
    
    private let bottomContainerImage3 = UIImageView().then {
        $0.image = UIImage(named: "img_waiting_bottom_3")
        $0.contentMode = .scaleAspectFill
    }
    
    private let gradientationView = UIView()
    
    let questionButton = UIButton().then {
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .bold(size: 16)
        $0.setTitle("waiting_question_button".localized, for: .normal)
        $0.backgroundColor = .green
        $0.layer.cornerRadius = 8
    }
    
    let logoutButton = UIButton().then {
        $0.setTitle("waiting_logout".localized, for: .normal)
        $0.setTitleColor(.gray40, for: .normal)
        $0.titleLabel?.font = .medium(size: 14)
    }
    
    override func setup() {
        self.backgroundColor = .gray95
        self.scrollViewContainerView.addSubViews([
            self.topContainerView,
            self.titleLabel,
            self.descriptionLabel,
            self.bottomContainerView,
            self.bottomContainerTitleLabel1,
            self.bottomContainerImage1,
            self.bottomContainerImage2,
            self.bottomContainerImage3
        ])
        self.scrollView.addSubview(self.scrollViewContainerView)
        self.addSubViews([
            self.scrollView,
            self.gradientationView,
            self.questionButton,
            self.logoutButton
        ])
        self.setupGradient()
    }
    
    override func bindConstraints() {
        self.scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide)
        }
        
        self.scrollViewContainerView.snp.makeConstraints { make in
            make.edges.equalTo(self.scrollView)
            make.width.equalTo(UIScreen.main.bounds.width)
            make.top.equalTo(self.titleLabel).priority(.high)
            make.bottom.equalTo(self.bottomContainerView).priority(.high)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(35)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
        }
        
        self.bottomContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(32)
            make.bottom.equalTo(self.bottomContainerImage3)
        }
        
        self.bottomContainerTitleLabel1.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.bottomContainerView).offset(56)
        }
        
        self.bottomContainerImage1.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.bottomContainerTitleLabel1.snp.bottom).offset(17)
        }
        
        self.bottomContainerImage2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.bottomContainerImage1.snp.bottom).offset(72)
        }
        
        self.bottomContainerImage3.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.bottomContainerImage2.snp.bottom).offset(72)
        }
        
        self.gradientationView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(180)
        }
        
        self.questionButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(self.logoutButton.snp.top).offset(-20)
            make.height.equalTo(48)
        }
        
        self.logoutButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
    private func setupGradient() {
        self.gradient.colors = [
            UIColor(r: 25, g: 25, b: 25, a: 0).cgColor,
            UIColor(r: 25, g: 25, b: 25, a: 1).cgColor,
            UIColor(r: 25, g: 25, b: 25, a: 1).cgColor
        ]
        self.gradient.locations = [0.0, 0.5, 1.0]
        self.gradient.startPoint = CGPoint(x: 0.5, y: 0)
        self.gradient.endPoint = CGPoint(x: 0.5, y: 1)
        self.gradient.frame.size = self.gradientationView.frame.size
        self.gradient.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 180)
        self.gradientationView.layer.addSublayer(gradient)
    }
}
