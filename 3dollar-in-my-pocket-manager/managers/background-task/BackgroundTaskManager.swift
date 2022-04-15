import BackgroundTasks

protocol BackgroundTaskManagerProtocol {
    func registerBackgroundTask()
}

final class BackgroundTaskManager: BackgroundTaskManagerProtocol {
    static let shared = BackgroundTaskManager()
    
    private let backgroundTaskId = "com.macgongmon.-dollar-in-my-pocket-manager-dev.background"
    
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: self.backgroundTaskId,
            using: nil
        ) { task in
            self.renewOpenState(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: self.backgroundTaskId)
        
        request.earliestBeginDate = Date(timeInterval: 5, since: Date())
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BGTaskScheduler.shared.submit")
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }
    
    private func renewOpenState(task: BGAppRefreshTask) {
        print("Background task")
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        self.scheduleBackgroundTask()
        task.setTaskCompleted(success: true)
    }
}
