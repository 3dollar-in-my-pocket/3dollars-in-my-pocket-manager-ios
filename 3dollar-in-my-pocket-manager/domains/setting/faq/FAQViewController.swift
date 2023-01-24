import UIKit

import ReactorKit
import RxSwift
import RxDataSources

final class FAQViewController: BaseViewController, View, FAQCoordinator {
    private let faqView = FAQView()
    private let faqReactor = FAQReactor(faqService: FAQService())
    private weak var coordinator: FAQCoordinator?
    private var faqCollectionViewDataSource
    : RxCollectionViewSectionedReloadDataSource<FAQSectionModel>!
    
    static func instance() -> FAQViewController {
        return FAQViewController(nibName: nil, bundle: nil).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func loadView() {
        self.view = self.faqView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupDataSource()
        self.reactor = self.faqReactor
        self.coordinator = self
        self.faqReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.faqView.backButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: FAQReactor) {
        // Bind State
        reactor.state
            .map { Dictionary(grouping: $0.faqs, by: { $0.category }) }
            .map { $0.values.map(FAQSectionModel.init(faqs:)) }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.faqView.collectionView.rx.items(dataSource: self.faqCollectionViewDataSource))
            .disposed(by: self.disposeBag)
    }
    
    private func setupDataSource() {
        self.faqCollectionViewDataSource
        = RxCollectionViewSectionedReloadDataSource<FAQSectionModel>(
            configureCell: { dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: FAQCollectionViewCell.registerId,
                    for: indexPath
                ) as? FAQCollectionViewCell else { return BaseCollectionViewCell() }
                
                cell.bind(faq: item)
                return cell
        })
        
        self.faqCollectionViewDataSource.configureSupplementaryView
        = { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: FAQHeaderView.registerId,
                    for: indexPath
                ) as? FAQHeaderView else { return UICollectionReusableView() }
                
                headerView.bind(title: dataSource[indexPath.section].categoryName)
                
                return headerView
                
            default:
                return UICollectionReusableView()
            }
        }
    }
}
