import Base

protocol HomeCoordinator: AnyObject, BaseCoordinator {
    func showInvalidPositionAlert()
}

extension HomeCoordinator {
    func showInvalidPositionAlert() {
        AlertUtils.showWithAction(
            viewController: self.presenter,
            title: nil,
            message: "home_invalid_position".localized,
            okbuttonTitle: "common_ok".localized,
            onTapOk: nil
        )
    }
}
