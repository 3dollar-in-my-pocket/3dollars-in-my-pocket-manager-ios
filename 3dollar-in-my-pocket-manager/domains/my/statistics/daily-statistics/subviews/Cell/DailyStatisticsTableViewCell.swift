import UIKit

final class DailyStatisticsCell: BaseCollectionViewCell {
    private let dayView = DailyStatisticsDayView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    override func setup() {
        setupLayout()
    }
    
    private func setupLayout() {
        addSubViews([
            dayView,
            stackView
        ])
        
        dayView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview()
            $0.size.equalTo(DailyStatisticsDayView.Layout.size)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.equalTo(dayView.snp.trailing).offset(11)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
            $0.trailing.equalToSuperview()
        }
    }
    
    func bind(
        feedbackGroup: FeedbackGroupingDateResponse,
        feedbackTypes: [FeedbackTypeResponse]
    ) {
        dayView.bind(dateString: feedbackGroup.date)
        for feedback in feedbackGroup.feedbacks {
            guard let feedbackType = getFeedbackType(from: feedbackTypes, feedback: feedback) else { continue }
            
            let itemView = DailyStatisticsStackItemView()
            itemView.bind(feedback: feedback, feedbackType: feedbackType)
            
            stackView.addArrangedSubview(itemView)
        }
    }
    
    private func getFeedbackType(
        from feedbackTypes: [FeedbackTypeResponse],
        feedback: FeedbackCountResponse
    ) -> FeedbackTypeResponse? {
        return feedbackTypes.first { $0.feedbackType == feedback.feedbackType }
    }
}
