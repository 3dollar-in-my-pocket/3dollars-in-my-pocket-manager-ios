protocol MyStoreInfoCoordinator: AnyObject, BaseCoordinator {
    func pushEditStoreInfo(store: Store)
    
    func pushEditIntroduction(storeId: String, introduction: String?)
}

extension MyStoreInfoCoordinator {
    func pushEditStoreInfo(store: Store) {
        
    }
    
    func pushEditIntroduction(storeId: String, introduction: String?) {
        let viewController = EditIntroductionViewController.instance(
            storeId: storeId,
            introduction: introduction
        )
        
        viewController.delegate = self as? EditIntroductionDelegate
        self.presenter.parent?
            .navigationController?
            .pushViewController(viewController, animated: true)
    }
}
