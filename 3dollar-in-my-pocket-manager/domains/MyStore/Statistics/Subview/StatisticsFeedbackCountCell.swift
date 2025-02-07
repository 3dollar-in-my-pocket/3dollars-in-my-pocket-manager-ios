import UIKit

final class StatisticsFeedbackCountCell: BaseCollectionViewCell {
    enum Layout {
        static func calculateHeight(viewModel: StatisticsFeedbackCountCellViewModel) -> CGFloat {
            let collectionViewHeight = calculateCollectionViewHeight(viewModel: viewModel)
            
            return collectionViewHeight + 84
        }
        
        static func calculateCollectionViewHeight(viewModel: StatisticsFeedbackCountCellViewModel) -> CGFloat {
            var numberOfLines: CGFloat = viewModel.output.statistics.isEmpty ? 0 : 1
            let screenWidth = UIUtils.windowBounds.width - 80
            var currentWidth: CGFloat = 0
            
            for feedback in viewModel.output.statistics {
                guard let feedbackType = viewModel.output.feedbackTypes[feedback.feedbackType] else { continue }
                let itemWidth = FeedbackCell.Layout.calculateItemSize(feedback, feedbackType: feedbackType).width
                
                if currentWidth + itemWidth > screenWidth {
                    numberOfLines += 1
                    currentWidth = 0
                }
                currentWidth += itemWidth
                currentWidth += interItemSpace
            }
            
            let height = FeedbackCell.Layout.height * numberOfLines
            let lineSpace = max(numberOfLines - 1 , 0) * interLineSpace
            return height + lineSpace
        }
        static let interItemSpace: CGFloat = 4
        static let interLineSpace: CGFloat = 4
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 12)
        label.textColor = .green
        label.text = Strings.Statistics.FeedbackCount.title
        return label
    }()
    
    private let seeMoreButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = Assets.icArrowRight.image
            .resizeImage(scaledTo: 12)
            .withRenderingMode(.alwaysTemplate)
        
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = 18
        style.minimumLineHeight = 18
        config.attributedTitle = AttributedString(Strings.Statistics.FeedbackCount.seeMore, attributes: .init([
            .font: UIFont.medium(size: 12) as Any,
            .foregroundColor: UIColor.gray50,
            .paragraphStyle: style
        ]))
        config.imagePlacement = .trailing
        config.imagePadding = 2
        config.contentInsets = .zero
        let button = UIButton(configuration: config)
        button.tintColor = .gray50
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
        collectionView.register([
            FeedbackCell.self,
            BaseCollectionViewCell.self
        ])
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private var viewModel: StatisticsFeedbackCountCellViewModel?
    
    override func setup() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(seeMoreButton)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(collectionView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalTo(seeMoreButton)
        }
        
        seeMoreButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(seeMoreButton.snp.bottom).offset(10)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(viewModel: StatisticsFeedbackCountCellViewModel) {
        self.viewModel = viewModel
        
        let description = Strings.Statistics.FeedbackCount.description(viewModel.output.reviewCount)
        let coloredRange = NSString(string: description).range(of: Strings.Statistics.FeedbackCount.Description.colored(viewModel.output.reviewCount))
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = 28
        style.minimumLineHeight = 28
        
        let attributedString = NSMutableAttributedString(string: description, attributes: [
            .paragraphStyle: style,
            .foregroundColor: UIColor.gray95,
            .font: UIFont.semiBold(size: 20) as Any
        ])
        attributedString.addAttributes([
            .font: UIFont.semiBold(size: 20) as Any,
            .foregroundColor: UIColor.green
        ], range: coloredRange)
        
        descriptionLabel.attributedText = attributedString
        
        collectionView.reloadData()

        seeMoreButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapSeeMore)
            .store(in: &cancellables)
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Layout.interItemSpace
        layout.minimumLineSpacing = Layout.interLineSpace
        return layout
    }
}

extension StatisticsFeedbackCountCell {
    final class FeedbackCell: BaseCollectionViewCell {
        enum Layout {
            static func calculateItemSize(
                _ feedback: FeedbackCountWithRatioResponse,
                feedbackType: FeedbackTypeResponse
            ) -> CGSize {
                guard let font = UIFont.medium(size: 12) else { return .zero }
                let feedbackWidth = "\(feedbackType.emoji) \(feedbackType.description)".width(font: font, height: 18).rounded(.up)
                let countString = Strings.Statistics.FeedbackCount.Item.countFormat(feedback.count)
                let countWidth = countString.width(font: font, height: 18).rounded(.up)
                let width = feedbackWidth + countWidth + 24
                return CGSize(width: width.rounded(.up), height: height)
            }
            static let height: CGFloat = 30
        }
        
        private let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 4
            stackView.layoutMargins = .init(top: 6, left: 10, bottom: 6, right: 10)
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.backgroundColor = .gray0
            stackView.layer.cornerRadius = 15
            return stackView
        }()
        
        private let feedbackLabel: UILabel = {
            let label = UILabel()
            label.font = .medium(size: 12)
            label.textColor = .gray95
            return label
        }()
        
        private let countLabel: UILabel = {
            let label = UILabel()
            label.font = .medium(size: 12)
            label.textColor = .gray50
            return label
        }()
        
        override func setup() {
            contentView.addSubview(stackView)
            stackView.addArrangedSubview(feedbackLabel)
            stackView.addArrangedSubview(countLabel)
            stackView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        func bind(feedback: FeedbackCountWithRatioResponse, feedbackType: FeedbackTypeResponse) {
            feedbackLabel.text = "\(feedbackType.emoji) \(feedbackType.description)"
            countLabel.text = Strings.Statistics.FeedbackCount.Item.countFormat(feedback.count)
        }
    }
}

extension StatisticsFeedbackCountCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.output.statistics.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let feedback = viewModel?.output.statistics[safe: indexPath.item],
              let feedbackType = viewModel?.output.feedbackTypes[feedback.feedbackType] else { return BaseCollectionViewCell() }
        
        let cell: FeedbackCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.bind(feedback: feedback, feedbackType: feedbackType)
        return cell
    }
}

extension StatisticsFeedbackCountCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let feedback = viewModel?.output.statistics[safe: indexPath.item],
              let feedbackType = viewModel?.output.feedbackTypes[feedback.feedbackType] else { return .zero }
        
        return FeedbackCell.Layout.calculateItemSize(feedback, feedbackType: feedbackType)
    }
}
