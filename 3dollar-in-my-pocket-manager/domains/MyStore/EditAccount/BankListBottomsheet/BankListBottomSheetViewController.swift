import UIKit

import PanModal

final class BankListBottomSheetViewController: BaseViewController {
    private let viewModel: BankListBottomSheetViewModel
    private let bankListBottomSheetView = BankListBottomSheetView()
    private var datasource: [BossBank] = []
    
    init(viewModel: BankListBottomSheetViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = bankListBottomSheetView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        bankListBottomSheetView.collectionView.dataSource = self
    }
    
    private func bind() {
        // Event
        bankListBottomSheetView.closeButton.tapPublisher
            .throttleClick()
            .main
            .withUnretained(self)
            .sink { (owner: BankListBottomSheetViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        // Input
        bankListBottomSheetView.collectionView.didSelectItemPublisher
            .map { $0.item }
            .subscribe(viewModel.input.didSelectItem)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.bankList
            .combineLatest(viewModel.output.selectedIndex)
            .main
            .withUnretained(self)
            .sink { (owner: BankListBottomSheetViewController, value) in
                let (bankList, selectedIndex) = value
                owner.datasource = bankList
                owner.bankListBottomSheetView.collectionView.reloadData()
                
                if let selectedIndex {
                    DispatchQueue.main.async {
                        owner.bankListBottomSheetView.collectionView.selectItem(
                            at: IndexPath(item: selectedIndex, section: 0),
                            animated: false,
                            scrollPosition: .centeredVertically
                        )
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: BankListBottomSheetViewController, route: BankListBottomSheetViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
}

// MARK: Route
extension BankListBottomSheetViewController {
    private func handleRoute(_ route: BankListBottomSheetViewModel.Route) {
        switch route {
        case .dismiss:
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
        let cell: BankListCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        guard let bank = datasource[safe: indexPath.item] else { return cell }
        cell.bind(bank: bank)
        return cell
    }
}
