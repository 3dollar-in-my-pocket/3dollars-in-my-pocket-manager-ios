protocol EditIntroductionCoordinator: AnyObject, BaseCoordinator {
    func popWithIntroduction(introduction: String?)
}

extension EditIntroductionCoordinator {
    func popWithIntroduction(introduction: String?) {
        if let delegate = self as? EditIntroductionDelegate {
            delegate.onUpdateIntroduction(introduction: introduction)
        }
        self.presenter.navigationController?.popViewController(animated: true)
    }
}
