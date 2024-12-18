import UIKit

final class ToastView: UIView {
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .gray95
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        return containerView
    }()
    
    private let messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.font = .medium(size: 14)
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        
        return messageLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(message: String) {
        self.messageLabel.text = message
    }
    
    private func setup() {
        backgroundColor = .clear
        addSubview(containerView)
        addSubview(messageLabel)
    }
    
    private func bindConstraints() {
        messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        containerView.leftAnchor.constraint(equalTo: messageLabel.leftAnchor, constant: -16).isActive = true
        containerView.rightAnchor.constraint(equalTo: messageLabel.rightAnchor, constant: 16).isActive = true
        containerView.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: messageLabel.heightAnchor, constant: 32).isActive = true
    }
}
