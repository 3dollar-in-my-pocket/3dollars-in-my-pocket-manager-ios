protocol MyStoreInfoCoordinator: AnyObject, BaseCoordinator {
    func pushEditSchedule(store: Store)
}

extension MyStoreInfoCoordinator {
    func pushEditSchedule(store: Store) {
        let viewController = EditScheduleViewController.instance(store: store)
        
        self.presenter.parent?
            .navigationController?
            .pushViewController(viewController, animated: true)
    }
}
