import UIKit

protocol EditAccountCoordinator: BaseCoordinator, AnyObject {
    func presentBankListBottomSheet(reactor: BankListBottomSheetReactor)
}

extension EditAccountCoordinator where Self: EditAccountViewController {
    func presentBankListBottomSheet(reactor: BankListBottomSheetReactor) {
        let viewController = BankListBottomSheetViewController(reactor: reactor)
        
        presenter.presentPanModal(viewController)
    }
}
