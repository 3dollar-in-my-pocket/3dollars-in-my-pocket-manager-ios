import UIKit

final class TooltipView: BaseView {
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.layoutMargins = .init(top: 8, left: 12, bottom: 8, right: 12)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.backgroundColor = UIColor(r: 35, g: 36, b: 42)
        stackView.layer.cornerRadius = 8
        stackView.layer.masksToBounds = true
        return stackView
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 16)
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let tailDirection: TailDirection
    
    init(emoji: String, message: String, tailDirection: TailDirection) {
        self.tailDirection = tailDirection
        super.init(frame: .zero)
        
        bind(emoji: emoji, message: message)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        addSubview(stackView)
        stackView.addArrangedSubview(emojiLabel)
        stackView.addArrangedSubview(messageLabel)
        
        setupTriangleView()
    }
    
    private func setupTriangleView() {
        let triangleView = tailDirection.triangleView
        addSubview(triangleView)
        
        switch tailDirection {
        case .bottomCenter:
            stackView.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
            }
            
            triangleView.snp.makeConstraints {
                $0.centerX.equalTo(stackView)
                $0.top.equalTo(stackView.snp.bottom)
                $0.width.equalTo(10)
                $0.height.equalTo(6)
            }
            
            snp.makeConstraints {
                $0.leading.top.trailing.equalTo(stackView)
                $0.bottom.equalTo(triangleView)
            }
        case .topRight:
            stackView.snp.makeConstraints {
                $0.top.equalTo(triangleView.snp.bottom)
                $0.bottom.leading.trailing.equalToSuperview()
            }
            
            triangleView.snp.makeConstraints {
                $0.trailing.equalTo(stackView).offset(-21)
                $0.width.equalTo(10)
                $0.height.equalTo(6)
                $0.top.equalToSuperview()
            }
            
            snp.makeConstraints {
                $0.leading.bottom.trailing.equalTo(stackView)
                $0.top.equalTo(triangleView)
            }
        }
    }
    
    private func bind(emoji: String, message: String) {
        emojiLabel.text = emoji
        
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = 20
        style.minimumLineHeight = 20
        
        let attributedString = NSMutableAttributedString(
            string: message,
            attributes: [
                .paragraphStyle: style,
                .font: UIFont.regular(size: 14) as Any,
                .foregroundColor: UIColor.white
            ]
        )
        messageLabel.attributedText = attributedString
    }
}

extension TooltipView {
    enum TailDirection {
        case topRight
        case bottomCenter
        
        var triangleView: UIView {
            switch self {
            case .topRight:
                return UpperTriangleView(width: 10, height: 6)
            case .bottomCenter:
                return LowerTriangleView(width: 10, height: 6)
            }
        }
    }
    
    final class UpperTriangleView: UIView {
        init(width: CGFloat, height: CGFloat) {
            let frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
            super.init(frame: frame)
            backgroundColor = .clear
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.close()
            
            UIColor(r: 35, g: 36, b: 42).setFill()
            path.fill()
        }
    }
    
    final class LowerTriangleView: UIView {
        init(width: CGFloat, height: CGFloat) {
            let frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
            super.init(frame: frame)
            backgroundColor = .clear
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.close()
            
            UIColor(r: 35, g: 36, b: 42).setFill()
            path.fill()
        }
    }
}
