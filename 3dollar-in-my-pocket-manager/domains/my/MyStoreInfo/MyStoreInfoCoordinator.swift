protocol MyStoreInfoCoordinator: AnyObject, BaseCoordinator {
    func pushEditSchedule(store: Store)
    
    func pushEditAccount(reactor: EditAccountReactor)
}

extension MyStoreInfoCoordinator {
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
