import BackgroundTasks

import RxSwift

protocol BackgroundTaskManagerProtocol {
    func registerBackgroundTask()
    
    func cancelBackgroundTask()
}

final class BackgroundTaskManager: BackgroundTaskManagerProtocol {
    static let shared = BackgroundTaskManager()
    private let locationManager = LocationManager.shared
    private let storeService = StoreService()
    private let disposeBag = DisposeBag()
    
    private let backgroundTaskId
    = "com.macgongmon.-dollar-in-my-pocket-manager-dev.background"
    
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: self.backgroundTaskId,
            using: nil
        ) { task in
            self.renewOpenState(task: task as! BGAppRefreshTask)
        }
    }
    
    func cancelBackgroundTask() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: self.backgroundTaskId)
    }
    
    private func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: self.backgroundTaskId)
        
        request.earliestBeginDate = Date(timeInterval: 60 * 15, since: Date())
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BGTaskScheduler.shared.submit")
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }
    
    private func renewOpenState(task: BGAppRefreshTask) {
        self.locationManager.getCurrentLocation()
            .asSingle()
            .flatMap { [weak self] location -> Single<String> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return self.storeService.openStore(
                    storeId: "",
                    location: location
                )
                .asSingle()
            }
            .subscribe { isSuccess in
                task.setTaskCompleted(success: true)
            } onFailure: { error in
                task.setTaskCompleted(success: false)
            }
            .disposed(by: self.disposeBag)

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        self.scheduleBackgroundTask()
    }
}
