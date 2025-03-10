import UIKit

final class CommentView: BaseView {
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = .gray0
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 12)
        label.textColor = .gray80
        label.textAlignment = .left
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 12)
        label.textColor = .gray40
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray80
        label.numberOfLines = 0
        return label
    }()
    
    override func setup() {
        addSubViews([
            containerView,
            nameLabel,
            dateLabel,
            contentLabel
        ])
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalToSuperview()
            $0.bottom.equalTo(contentLabel).offset(12)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(16)
            $0.top.equalTo(containerView).offset(12)
            $0.trailing.lessThanOrEqualTo(dateLabel).offset(-16)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.trailing.equalTo(containerView).offset(-16)
        }
        
        contentLabel.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(16)
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.trailing.equalTo(containerView).offset(-16)
        }
        
        snp.makeConstraints {
            $0.top.equalTo(containerView)
            $0.bottom.equalTo(containerView)
        }
    }
    
    func bind(comment: CommentResponse) {
        nameLabel.text = comment.writer.name
        dateLabel.text = DateUtils.toString(dateString: comment.createdAt, format: "yyyy.MM.dd")
        contentLabel.text = comment.content
        contentLabel.setLineHeight(lineHeight: 20)
    }
}
