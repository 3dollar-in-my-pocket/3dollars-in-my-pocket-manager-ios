import UIKit

final class TotalStatisticsItemView: BaseView {
    enum Layout {
        static let height: CGFloat = 50
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 14)
        label.textColor = .gray95
        return label
    }()
    
    private let countLabel: PaddingLabel = {
        let label = PaddingLabel(
            topInset: 4,
            bottomInset: 4,
            leftInset: 8,
            rightInset: 8
        )
        label.font = .regular(size: 12)
        label.textColor = .green
        label.layer.borderColor = UIColor.green.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 11
        return label
    }()
    
    private let progressBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 242, g: 251, b: 247)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = .green
        progressView.layer.cornerRadius = 4
        progressView.trackTintColor = .clear
        return progressView
    }()
    
    override func setup() {
        backgroundColor = .clear
        setupLayout()
    }
    
    private func setupLayout() {
        addSubViews([
            titleLabel,
            countLabel,
            progressBackgroundView,
            progressView
        ])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(countLabel).offset(2)
        }
        
        countLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        progressBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(16)
            $0.bottom.equalToSuperview()
        }
        
        progressView.snp.makeConstraints {
            $0.leading.equalTo(progressBackgroundView).offset(4)
            $0.top.equalTo(progressBackgroundView).offset(4)
            $0.trailing.equalTo(progressBackgroundView).offset(-4)
            $0.bottom.equalTo(progressBackgroundView).offset(-4)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }
    
    func bind(
        feedback: FeedbackCountWithRatioResponse,
        feedbackType: FeedbackTypeResponse,
        isTopRate: Bool
    ) {
        titleLabel.text = "\(feedbackType.emoji) \(feedbackType.description)"
        countLabel.text = "\(feedback.count)개"
        progressView.progress = Float(feedback.ratio)
        setProgressBar(isTopRate: feedback.count == 0 ? false : isTopRate)
    }
    
    private func setProgressBar(isTopRate: Bool) {
        progressBackgroundView.backgroundColor = isTopRate ? UIColor(r: 242, g: 251, b: 247) : .gray5
        progressView.progressTintColor = isTopRate ? .green : .gray10
    }
}
