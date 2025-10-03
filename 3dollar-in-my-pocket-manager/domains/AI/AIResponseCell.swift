import UIKit
import Down

enum MarkdownError: LocalizedError {
    case loadMarkdownFailed
    
    var errorDescription: String? {
        switch self {
        case .loadMarkdownFailed:
            return "AI 응답 처리 중 오류가 발생했습니다.\n당겨서 새로고침으로 재시도해주세요."
        }
    }
}

final class AIResponseCell: BaseCollectionViewCell {
    enum Layout {
        static let bottomPadding: CGFloat = 12
    }
    
    private let markdownLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 16)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    override func setup() {
        super.setup()
        
        contentView.addSubview(markdownLabel)
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        markdownLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().offset(19)
            $0.bottom.equalToSuperview().offset(-Layout.bottomPadding)
        }
    }
    
    func bind(viewModel: AIResponseCellViewModel) {
        do {
            let down = Down(markdownString: viewModel.output.markdown)
            let cssStyle = """
            body {
                font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, sans-serif;
                font-size: 16px;
                font-weight: 400;
                line-height: 24px;
                letter-spacing: -0.16px;
                color: #000000;
                margin: 0;
                padding: 0;
            }

            p {
                margin: 0 0 16px 0;
                font-size: 16px;
                font-weight: 400;
                line-height: 24px;
                letter-spacing: -0.16px;
            }

            strong, b {
                font-weight: 700;
                letter-spacing: -0.16px;
            }

            h1, h2, h3, h4, h5, h6 {
                margin: 0 0 16px 0;
                line-height: 24px;
                letter-spacing: -0.16px;
            }

            ul, ol {
                margin: 0 0 16px 0;
                padding-left: 20px;
            }

            li {
                margin-bottom: 8px;
                line-height: 24px;
                letter-spacing: -0.16px;
            }
            """

            let attributedString = try down.toAttributedString(stylesheet: cssStyle)
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            mutableAttributedString.enumerateAttribute(
                .font,
                in: NSRange(location: 0, length: mutableAttributedString.length),
                options: []
            ) { value, range, _ in
                guard let currentFont = value as? UIFont else { return }
                
                
                let isBold = currentFont.fontDescriptor.symbolicTraits.contains(.traitBold)
                let pretendardFont: UIFont
                
                if isBold {
                    pretendardFont = .bold(size: currentFont.pointSize) ?? currentFont
                } else {
                    pretendardFont = .regular(size: currentFont.pointSize) ?? currentFont
                }
                
                mutableAttributedString.addAttribute(.font, value: pretendardFont, range: range)
            }
            
            mutableAttributedString.addAttributes([
                .foregroundColor: UIColor.black,
                .kern: 16 * (-1 / 100)
            ], range: NSRange(location: 0, length: mutableAttributedString.length))
            
            markdownLabel.attributedText = mutableAttributedString
        } catch {
            viewModel.input.onError.send(MarkdownError.loadMarkdownFailed)
        }
    }
}
