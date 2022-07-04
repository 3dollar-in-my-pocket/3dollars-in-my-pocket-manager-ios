import UIKit

import Base
import ReactorKit

final class EditScheduleViewController:
    BaseViewController, View, EditScheduleCoordinator {
    private let editScheduleView = EditScheduleView()
    private let editScheduleReactor: EditScheduleReactor
    private weak var coordinator: EditScheduleCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    static func instance(store: Store) -> EditScheduleViewController {
        return EditScheduleViewController(store: store).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    init(store: Store) {
        self.editScheduleReactor = EditScheduleReactor(
            store: store,
            storeService: StoreService(),
            globalState: GlobalState.shared
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.editScheduleView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.editScheduleReactor
    }
    
    override func bindEvent() {
        self.editScheduleView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editScheduleReactor.popPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editScheduleReactor.showLoadginPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editScheduleReactor.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: EditScheduleReactor) {
        // Bind Action
        self.editScheduleView.weekDayStackView.rx.tap
            .map { Reactor.Action.tapDayOfTheWeek($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.editScheduleView.saveButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapEditButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.store.appearanceDays.map { $0.dayOfTheWeek } }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.editScheduleView.weekDayStackView.rx.selectedDay)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.store.appearanceDays }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.editScheduleView.tableView.rx.items(
                cellIdentifier: EditScheduleTableViewCell.registerId,
                cellType: EditScheduleTableViewCell.self
            )) { row, appearanceDay, cell in
                cell.bind(appearanceDay: appearanceDay)
                cell.startTimeField.rx.date
                    .map {
                        Reactor.Action.inputStartTime(day: appearanceDay.dayOfTheWeek, time: $0)
                    }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
                cell.endTimeField.rx.date
                    .map {
                        Reactor.Action.inputEndTime(day: appearanceDay.dayOfTheWeek, time: $0)
                    }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
                cell.locationField.rx.text
                    .map {
                        Reactor.Action.inputLocation(day: appearanceDay.dayOfTheWeek, location: $0)
                    }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: self.disposeBag)
    }
}
