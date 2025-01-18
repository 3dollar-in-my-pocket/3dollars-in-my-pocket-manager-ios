import UIKit
import CombineCocoa

final class StatisticsBookmarkCountCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 108
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        return view
    }()
    
    private let bookmarkIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Assets.icBookmarkSolid.image.resizeImage(scaledTo: 16)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 12)
        label.textColor = .green
        label.text = Strings.Statistics.BookmarkCount.title
        return label
    }()
    
    private let sendMessageButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = Assets.icArrowRight.image
            .resizeImage(scaledTo: 12)
            .withRenderingMode(.alwaysTemplate)
        
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = 18
        style.minimumLineHeight = 18
        config.attributedTitle = AttributedString(Strings.Statistics.BookmarkCount.message, attributes: .init([
            .font: UIFont.medium(size: 12) as Any,
            .foregroundColor: UIColor.gray50,
            .paragraphStyle: style
        ]))
        config.imagePlacement = .trailing
        config.imagePadding = 2
        let button = UIButton(configuration: config)
        button.tintColor = .gray50
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    override func setup() {
        contentView.addSubview(containerView)
        containerView.addSubview(bookmarkIcon)
        containerView.addSubview(titleLabel)
        containerView.addSubview(sendMessageButton)
        containerView.addSubview(descriptionLabel)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bookmarkIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(13)
            $0.size.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(bookmarkIcon)
            $0.leading.equalTo(bookmarkIcon.snp.trailing).offset(1)
        }
        
        sendMessageButton.snp.makeConstraints {
            $0.centerY.equalTo(bookmarkIcon)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(bookmarkIcon.snp.bottom).offset(10)
        }
    }
    
    func bind(viewModel: StatisticsBookmarkCountCellViewModel) {
        let description = Strings.Statistics.BookmarkCount.description(viewModel.output.bookmarkCount)
        let coloredRange = NSString(string: description).range(of: Strings.Statistics.BookmarkCount.Description.colord(viewModel.output.bookmarkCount))
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
        
        sendMessageButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapSendMessage)
            .store(in: &cancellables)
    }
}
