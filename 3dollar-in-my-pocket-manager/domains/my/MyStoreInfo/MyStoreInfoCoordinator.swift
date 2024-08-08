protocol MyStoreInfoCoordinator: AnyObject, BaseCoordinator {
    func pushEditStoreInfo(store: Store)
    
    func pushEditIntroduction(store: Store)
    
    func pushEditMenu(store: Store)
    
    func pushEditSchedule(store: Store)
    
    func pushEditAccount(reactor: EditAccountReactor)
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
    
    func pushEditAccount(reactor: EditAccountReactor) {
        let viewController = EditAccountViewController(reactor: reactor)
        
        presenter.parent?
            .navigationController?
            .pushViewController(viewController, animated: true)
    }
}
