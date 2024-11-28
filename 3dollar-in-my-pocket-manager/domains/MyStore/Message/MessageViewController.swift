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
    
    private let refreshControl = UIRefreshControl()
    
    private let viewModel: MessageViewModel
    private lazy var dataSource = MessageDataSource(collectionView: collectionView)
    private var timer: Timer?
    private var isRefreshing: Bool = false
    
    init(viewModel: MessageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        collectionView.delegate = self
        viewModel.input.firstLoad.send(())
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(messageButton)
        collectionView.refreshControl = refreshControl
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        messageButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            $0.trailing.equalToSuperview().offset(-12)
        }
    }
    
    private func bind() {
        refreshControl.isRefreshingPublisher
            .filter { $0 }
            .withUnretained(self)
            .sink { (owner: MessageViewController, _) in
                owner.isRefreshing = true
            }
            .store(in: &cancellables)
        
        messageButton.tapPublisher
            .subscribe(viewModel.input.didTapSendingMessage)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.datasource
            .main
            .withUnretained(self)
            .sink { (owner: MessageViewController, sections: [MessageSection]) in
                owner.dataSource.reload(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.policy
            .main
            .withUnretained(self)
            .sink { (owner: MessageViewController, policy: StoreMessagePolicyResponse) in
                owner.setupSendingButton(policy: policy)
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: MessageViewController, error: any Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: MessageViewController, route: MessageViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
        
        viewModel.output.isRefreshing
            .filter { $0.isNot }
            .main
            .withUnretained(self)
            .sink { (owner: MessageViewController, _) in
                owner.refreshControl.endRefreshing()
                owner.isRefreshing = false
            }
            .store(in: &cancellables)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
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
            case .message:
                let messageItem = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MessageHistoryCell.Layout.estimatedHeight)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(MessageHistoryCell.Layout.estimatedHeight)
                ), subitems: [messageItem])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 0
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(MessageHistoryHeaderView.Layout.height)
                )
                let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [headerItem]
                
                return section
            }
        }
        return layout
    }
    
    private func setupSendingButton(policy: StoreMessagePolicyResponse) {
        if policy.canSendNow {
            messageButton.backgroundColor = .green
            messageButton.configuration?.attributedTitle = AttributedString(Strings.Message.sendMessage, attributes: .init([
                .font: UIFont.medium(size: 14) as Any,
                .foregroundColor: UIColor.white
            ]))
            messageButton.isEnabled = true
        } else {
            messageButton.backgroundColor = .gray40
            
            let nextAvailableSendDate = DateUtils.toDate(dateString: policy.nextAvailableSendDateTime)
            messageButton.isEnabled = false
            startCountdown(to: nextAvailableSendDate)
        }
    }
    
    private func startCountdown(to targetDate: Date) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { return }

            let currentTime = Date()
            if currentTime >= targetDate {
                timer.invalidate() // 시간이 다 되면 타이머 멈추기
                messageButton.backgroundColor = .green
                messageButton.configuration?.attributedTitle = AttributedString(Strings.Message.sendMessage, attributes: .init([
                    .font: UIFont.medium(size: 14) as Any,
                    .foregroundColor: UIColor.white
                ]))
                messageButton.isEnabled = true
            } else {
                let remainingTime = timeDifferenceBetween(currentTime, targetDate)
                messageButton.configuration?.attributedTitle = AttributedString(remainingTime + " 후 발송 가능", attributes: .init([
                    .font: UIFont.medium(size: 14) as Any,
                    .foregroundColor: UIColor.white
                ]))
            }
        }
    }
    
    private func timeDifferenceBetween(_ fromDate: Date, _ toDate: Date) -> String {
        let timeInterval = toDate.timeIntervalSince(fromDate)
        
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

extension MessageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard dataSource.sectionIdentifier(section: indexPath.section)?.type == .message else { return }
        
        viewModel.input.willDisplay.send(indexPath.item)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard isRefreshing else  { return }
        
        viewModel.input.refresh.send(())
    }
}


// MARK: Route
extension MessageViewController {
    private func handleRoute(_ route: MessageViewModel.Route) {
        switch route {
        case .sendingMessage(let viewModel):
            presentSendingMessage(viewModel: viewModel)
        case .confirmMessage(let viewModel):
            presentConfirmMEssage(viewModel: viewModel)
        }
    }
    
    private func presentSendingMessage(viewModel: SendingMessageViewModel) {
        let viewController = SendingMessageViewController(viewModel: viewModel)
        presentPanModal(viewController)
    }
    
    private func presentConfirmMEssage(viewModel: ConfirmMessageViewModel) {
        let viewController = ConfirmMessageViewController(viewModel: viewModel)
        tabBarController?.present(viewController, animated: true)
    }
}
