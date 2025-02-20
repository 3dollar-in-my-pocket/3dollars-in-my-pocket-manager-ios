import UIKit
import PanModal

final class ReviewReportBottomSheet: BaseViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray100
        label.font = .semiBold(size: 20)
        label.text = "신고사유를 입력해주세요."
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Assets.icDeleteX.image, for: .normal)
        return button
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray50
        label.text = "관리자 판단 후 리뷰를 삭제해드립니다."
        return label
    }()
    
    private let textViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .regular(size: 14)
        textView.textColor = .gray95
        textView.backgroundColor = .clear
        return textView
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray50
        label.font = .medium(size: 12)
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "*최소 10자에서 최대 300자 이내로 입력해 주세요."
        label.font = .medium(size: 12)
        label.textColor = .gray50
        return label
    }()
    
    private let reportButton: UIButton = {
        let button = UIButton()
        button.setBackgroundColor(color: .gray30, forState: .disabled)
        button.setBackgroundColor(color: .red, forState: .normal)
        button.setTitle("신고하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .semiBold(size: 14)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(subTitleLabel)
        view.addSubview(textViewContainer)
        textViewContainer.addSubview(textView)
        textViewContainer.addSubview(countLabel)
        view.addSubview(infoLabel)
        view.addSubview(reportButton)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-16)
        }
        
        closeButton.snp.makeConstraints {
            $0.size.equalTo(30)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleLabel)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        textViewContainer.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(16)
            $0.height.equalTo(300)
        }
        
        textView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-36)
        }
        
        countLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        infoLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(textViewContainer.snp.bottom).offset(4)
        }
        
        reportButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(infoLabel.snp.bottom).offset(28)
            $0.height.equalTo(48)
        }
    }
}

extension ReviewReportBottomSheet: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(516)
    }
    
    var longFormHeight: PanModalHeight {
        return shortFormHeight
    }
    
    var showDragIndicator: Bool {
        return false
    }
}
