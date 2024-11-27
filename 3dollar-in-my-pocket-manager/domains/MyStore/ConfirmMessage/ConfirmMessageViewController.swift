import UIKit

final class ConfirmMessageViewController: BaseViewController {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 20)
        label.textColor = .gray100
        label.numberOfLines = 0
        
        let text = "정말 아래의 메세지로 전송하시나요?\n다시 한 번 확인해 주세요."
        let style = NSMutableParagraphStyle()
        
        style.maximumLineHeight = 28
        style.minimumLineHeight = 28
        style.alignment = .center
        label.attributedText = NSMutableAttributedString(string: text, attributes: [.paragraphStyle: style,])
        return label
    }()
    
    private let messageView = MessageView()
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("메세지 전송", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .bold(size: 14)
        return button
    }()
    
    let reWriteButton: UIButton = {
        let button = UIButton()
        button.setTitle("다시 쓰기", for: .normal)
        button.setTitleColor(.green, for: .normal)
        button.titleLabel?.font = .bold(size: 14)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.green.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        if let parentView = presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        
        view.addSubViews([
            containerView,
            stackView
        ])
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(8, after: titleLabel)
        stackView.addArrangedSubview(messageView)
        stackView.setCustomSpacing(24, after: messageView)
        stackView.addArrangedSubview(sendButton)
        stackView.setCustomSpacing(8, after: sendButton)
        stackView.addArrangedSubview(reWriteButton)
        
        sendButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        reWriteButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(containerView).offset(20)
            $0.trailing.equalTo(containerView).offset(-20)
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(stackView).offset(-24)
            $0.bottom.equalTo(stackView).offset(24)
        }
    }
}


extension ConfirmMessageViewController {
    final class MessageView: BaseView {
        private let horizontalStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.layoutMargins = .init(top: 10, left: 16, bottom: 10, right: 16)
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.alignment = .top
            return stackView
        }()
        
        private let emojiView: UILabel = {
            let label = UILabel()
            label.text = "💌"
            label.font = .regular(size: 14)
            return label
        }()
        
        private let verticalStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 8
            return stackView
        }()
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.textColor = .gray95
            label.font = .semiBold(size: 14)
            label.text = "내가 즐겨 찾은 가게 은평구 핫도그 아저씨의 메세지가 도착하였습니다."
            label.numberOfLines = 0
            label.textAlignment = .left
            label.setLineHeight(lineHeight: 20)
            return label
        }()
        
        private let messageLabel: UILabel = {
            let label = UILabel()
            label.textColor = .gray95
            label.font = .regular(size: 14)
            label.numberOfLines = 0
            label.textAlignment = .left
            label.text = "성원에 감사합니다 여러분~~~~매일 매일 감사합니다. 잘때도 생각합니다 어제 꿈에도 나왔습니당"
            label.setLineHeight(lineHeight: 20)
            return label
        }()
        
        override func setup() {
            setupUI()
        }
        
        private func setupUI() {
            backgroundColor = .gray10
            layer.cornerRadius = 12
            layer.masksToBounds = true
            
            addSubview(horizontalStackView)
            horizontalStackView.addArrangedSubview(emojiView)
            horizontalStackView.addArrangedSubview(verticalStackView)
            
            verticalStackView.addArrangedSubview(titleLabel)
            verticalStackView.addArrangedSubview(messageLabel)
            
            emojiView.snp.makeConstraints {
                $0.width.equalTo(20)
                $0.height.equalTo(20)
            }
            
            horizontalStackView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            snp.makeConstraints {
                $0.edges.equalTo(horizontalStackView)
            }
        }
    }
}
