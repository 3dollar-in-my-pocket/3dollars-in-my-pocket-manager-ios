import UIKit

final class ReviewDetailCommentView: BaseView {
    private let triangleView = TriangleView()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .gray10
        stackView.layer.cornerRadius = 12
        stackView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        stackView.axis = .vertical
        stackView.layoutMargins = .init(top: 12, left: 16, bottom: 12, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 12)
        label.textColor = .gray80
        return label
    }()
    
    private let createdAtLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 12)
        label.textColor = .gray40
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray80
        label.numberOfLines = 0
        return label
    }()
    
    private let deleteCommentButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = Assets.icTrash.image.resizeImage(scaledTo: 16).withRenderingMode(.alwaysTemplate)
        config.imagePadding = 4
        config.attributedTitle = AttributedString(Strings.ReviewDetail.Comment.deleteComment, attributes: .init([
            .font: UIFont.regular(size: 12) as Any,
            .foregroundColor: UIColor.gray80
        ]))
        let button = UIButton(configuration: config)
        button.tintColor = .gray50
        return button
    }()
    
    override func setup() {
        addSubViews([
            triangleView,
            containerStackView,
            deleteCommentButton
        ])
        
        triangleView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.width.equalTo(16)
            make.height.equalTo(12)
            make.top.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(triangleView.snp.bottom)
        }
        
        deleteCommentButton.snp.makeConstraints { make in
            make.top.equalTo(containerStackView.snp.bottom).offset(8)
            make.trailing.equalTo(containerStackView)
            make.height.equalTo(34)
        }
        
        snp.makeConstraints { make in
            make.top.equalTo(triangleView).priority(.high)
            make.bottom.equalTo(deleteCommentButton).priority(.high)
        }
        
        let titleStackView = UIStackView()
        titleStackView.axis = .horizontal
        titleStackView.addArrangedSubview(nameLabel)
        titleStackView.addArrangedSubview(UIView())
        titleStackView.addArrangedSubview(createdAtLabel)
        
        containerStackView.addArrangedSubview(titleStackView)
        containerStackView.setCustomSpacing(8, after: titleStackView)
        containerStackView.addArrangedSubview(commentLabel)
    }
    
    func bind(comment: CommentResponse, name: String) {
        nameLabel.text = name
        createdAtLabel.text = DateUtils.toString(dateString: comment.createdAt, format: "yyyy-MM-dd")
        commentLabel.text = comment.content
    }
}

extension ReviewDetailCommentView {
    final class TriangleView: UIView {
        override func draw(_ rect: CGRect) {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // 좌측 상단
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // 우측 하단
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY)) // 중앙 삼각형 꼭짓점
            path.close()
            
            UIColor.gray10.setFill()
            path.fill()
        }
    }
}
