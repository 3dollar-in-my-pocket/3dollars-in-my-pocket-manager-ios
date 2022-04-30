protocol MyStoreInfoCoordinator: AnyObject, BaseCoordinator {
    func pushEditStoreInfo(store: Store)
    
    func pushEditIntroduction(store: Store)
}

extension MyStoreInfoCoordinator {
    func pushEditStoreInfo(store: Store) {
        let viewController = EditStoreInfoViewController.instance(store: store)
        
        self.presenter.parent?
            .navigationController?
            .pushViewController(viewController, animated: true)
    }
    
    func pushEditIntroduction(store: Store) {
        let viewController = EditIntroductionViewController.instance(store: store)
        
        self.presenter.parent?
            .navigationController?
            .pushViewController(viewController, animated: true)
    }
}
