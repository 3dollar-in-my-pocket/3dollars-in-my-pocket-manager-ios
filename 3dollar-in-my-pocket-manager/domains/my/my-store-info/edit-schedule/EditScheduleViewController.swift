import UIKit

final class EditScheduleViewController: BaseViewController, EditScheduleCoordinator {
    private let editScheduleView = EditScheduleView()
    private weak var coordinator: EditScheduleCoordinator?
    
    static func instance(store: Store) -> EditScheduleViewController {
        return EditScheduleViewController(store: store).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    init(store: Store) {
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
        self.editScheduleView.tableView.dataSource = self
    }
    
    override func bindEvent() {
        self.editScheduleView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
    }
}

extension EditScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EditScheduleTableViewCell.registerId,
            for: indexPath
        ) as? EditScheduleTableViewCell else { return BaseTableViewCell() }
        
        return cell
    }
}
