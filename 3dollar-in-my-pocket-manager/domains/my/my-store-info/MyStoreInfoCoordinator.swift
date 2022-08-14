protocol MyStoreInfoCoordinator: AnyObject, BaseCoordinator {
    func pushEditStoreInfo(store: Store)
    
    func pushEditIntroduction(store: Store)
    
    func pushEditMenu(store: Store)
    
    func pushEditSchedule(store: Store)
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
    
    func pushEditMenu(store: Store) {
        let viewController = EditMenuViewController.instance(store: store)
        
        self.presenter.parent?
            .navigationController?
            .pushViewController(viewController, animated: true)
    }
    
    func pushEditSchedule(store: Store) {
        let viewController = EditScheduleViewController.instance(store: store)
        
        self.presenter.parent?
            .navigationController?
            .pushViewController(viewController, animated: true)
    }
}
