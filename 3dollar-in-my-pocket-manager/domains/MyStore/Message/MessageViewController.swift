import UIKit
import CombineCocoa

final class MessageViewController: BaseViewController {
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let messageButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.Message.sendMessage, attributes: .init([
            .font: UIFont.medium(size: 14) as Any,
            .foregroundColor: UIColor.white
        ]))
        config.image = Assets.icCommunitySolid.image.resizeImage(scaledTo: 20)
        config.imagePadding = 4
        config.contentInsets = .init(top: 12, leading: 16, bottom: 12, trailing: 16)
        config.baseForegroundColor = .white
        let button = UIButton(configuration: config)
        button.backgroundColor = .green
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var dataSource = MessageDataSource(collectionView: collectionView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        dataSource.reload([.init(type: .first, items: [.toast, .firstTitle, .bookmark, .introduction])])
        
        messageButton.tapPublisher
            .main
            .withUnretained(self)
            .sink { (owner: MessageViewController, _) in
                let viewController = SendingMessageViewController(viewModel: SendingMessageViewModel())
                owner.presentPanModal(viewController)
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(messageButton)
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        messageButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            $0.trailing.equalToSuperview().offset(-12)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self,
                  let sectionType = dataSource.sectionIdentifier(section: sectionIndex)?.type else {
                fatalError("정의되지 않은 섹션입니다.")
            }
            
            switch sectionType {
            case .overview:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MessageOverviewCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MessageOverviewCell.Layout.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            case .first:
                let toastItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MessageDisableToastCell.Layout.height)
                ))
                let titleItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MessageFirstTitleCell.Layout.height)
                ))
                let bookmarkItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MessageBookmarkCell.Layout.height)
                ))
                let introductionItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MessageIntroductionCell.Layout.height)
                ))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MessageDisableToastCell.Layout.height + MessageFirstTitleCell.Layout.height + MessageBookmarkCell.Layout.height + MessageIntroductionCell.Layout.height)
                ), subitems: [toastItem, titleItem, bookmarkItem, introductionItem])
                group.interItemSpacing = .fixed(0)
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            }
            
        }
    }
}
