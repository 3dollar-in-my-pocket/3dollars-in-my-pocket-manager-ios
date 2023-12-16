import UIKit

import RxSwift
import ReactorKit
import PanModal

final class BankListBottomSheetViewController: BaseViewController, View {
    private let bankListBottomSheetView = BankListBottomSheetView()
    private var datasource: [BankListBottomSheetReactor.Item] = []
    
    init(reactor: BankListBottomSheetReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = bankListBottomSheetView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bankListBottomSheetView.collectionView.dataSource = self
    }
    
    override func bindEvent() {
        bankListBottomSheetView.closeButton.rx.tap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func bind(reactor: BankListBottomSheetReactor) {
        // Bind Action
        bankListBottomSheetView.collectionView.rx.itemSelected
            .map { Reactor.Action.didSelectItem($0.item) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.itemList }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] itemList in
                self?.datasource = itemList
                self?.bankListBottomSheetView.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$route)
            .compactMap { $0 }
            .bind(onNext: { [weak self] route in
                self?.handleRoute(route)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleRoute(_ route: BankListBottomSheetReactor.Route) {
        switch route {
        case .pop:
            dismiss(animated: true)
        }
    }
}

extension BankListBottomSheetViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(500)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeight
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var cornerRadius: CGFloat {
        return 16
    }
}

extension BankListBottomSheetViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BankListCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        
        guard let item = datasource[safe: indexPath.item] else { return cell }
        cell.bind(item: item)
        return cell
    }
}
