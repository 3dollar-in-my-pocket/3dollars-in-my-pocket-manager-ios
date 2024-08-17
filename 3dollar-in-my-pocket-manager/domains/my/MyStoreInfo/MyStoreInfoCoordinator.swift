protocol MyStoreInfoCoordinator: AnyObject, BaseCoordinator {
    func pushEditMenu(store: Store)
    
    func pushEditSchedule(store: Store)
    
    func pushEditAccount(reactor: EditAccountReactor)
}

extension MyStoreInfoCoordinator {
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
