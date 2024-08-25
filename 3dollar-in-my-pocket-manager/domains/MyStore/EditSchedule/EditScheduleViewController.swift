import UIKit

final class EditScheduleViewController: BaseViewController {
    private let viewModel: EditScheduleViewModel
    private let editScheduleView = EditScheduleView()
    
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    init(viewModel: EditScheduleViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = editScheduleView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    private func bind() {
        // Event
        editScheduleView.backButton.tapPublisher
            .throttleClick()
            .main
            .withUnretained(self)
            .sink { (owner: EditScheduleViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        // Input
        editScheduleView.weekDayStackView.tapPublisher
            .subscribe(viewModel.input.didTapDayOfTheWeek)
            .store(in: &cancellables)
        
        editScheduleView.saveButton.tapPublisher
            .subscribe(viewModel.input.didTapSaveButton)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.store
            .main
            .withUnretained(self)
            .sink { (owner: EditScheduleViewController, store: BossStoreResponse) in
                owner.bindStore(store)
            }
            .store(in: &cancellables)
        
        viewModel.output.toast
            .main
            .sink { message in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.showLoading
            .main
            .sink { isShow in
                LoadingManager.shared.showLoading(isShow: isShow)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: EditScheduleViewController, route: EditScheduleViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func bindStore(_ store: BossStoreResponse) {
        editScheduleView.weekDayStackView.bind(daysOfTheWeek: store.appearanceDays.map { $0.dayOfTheWeek })
        
        editScheduleView.clearItemViews()
        for appearanceDay in store.appearanceDays {
            let itemView = EditScheduleItemView()
            itemView.bind(appearanceDay: appearanceDay)
            
            itemView.startTimeField.textField.textPublisher
                .dropFirst()
                .compactMap { $0 }
                .map { (day: appearanceDay.dayOfTheWeek, time: $0) }
                .subscribe(viewModel.input.inputStartTime)
                .store(in: &itemView.cancellables)
            
            itemView.endTimeField.textField.textPublisher
                .dropFirst()
                .compactMap { $0 }
                .map { (day: appearanceDay.dayOfTheWeek, time: $0) }
                .subscribe(viewModel.input.inputEndTime)
                .store(in: &itemView.cancellables)
            
            itemView.locationField.textField.textPublisher
                .dropFirst()
                .compactMap { $0 }
                .map { (day: appearanceDay.dayOfTheWeek, location: $0) }
                .subscribe(viewModel.input.inputLocation)
                .store(in: &itemView.cancellables)
            editScheduleView.stackView.addArrangedSubview(itemView)
            editScheduleView.stackView.setCustomSpacing(16, after: itemView)
        }
    }
    
//    func bind(reactor: EditScheduleReactor) {
//        reactor.state
//            .map { $0.store.appearanceDays }
//            .distinctUntilChanged()
//            .asDriver(onErrorJustReturn: [])
//            .drive(self.editScheduleView.tableView.rx.items(
//                cellIdentifier: EditScheduleTableViewCell.registerId,
//                cellType: EditScheduleTableViewCell.self
//            )) { row, appearanceDay, cell in
//                cell.bind(appearanceDay: appearanceDay)
//                cell.startTimeField.rx.date
//                    .map {
//                        Reactor.Action.inputStartTime(day: appearanceDay.dayOfTheWeek, time: $0)
//                    }
//                    .bind(to: reactor.action)
//                    .disposed(by: cell.disposeBag)
//                cell.endTimeField.rx.date
//                    .map {
//                        Reactor.Action.inputEndTime(day: appearanceDay.dayOfTheWeek, time: $0)
//                    }
//                    .bind(to: reactor.action)
//                    .disposed(by: cell.disposeBag)
//                cell.locationField.rx.text
//                    .map {
//                        Reactor.Action.inputLocation(day: appearanceDay.dayOfTheWeek, location: $0)
//                    }
//                    .bind(to: reactor.action)
//                    .disposed(by: cell.disposeBag)
//            }
//            .disposed(by: self.disposeBag)
//    }
}


// MARK: Route
extension EditScheduleViewController {
    private func handleRoute(_ route: EditScheduleViewModel.Route) {
        switch route {
        case .pop:
            navigationController?.popViewController(animated: true)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}
