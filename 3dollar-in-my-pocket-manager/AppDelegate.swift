import UIKit
import BackgroundTasks

import KakaoSDKCommon
import FirebaseCore
import FirebaseMessaging
import Then
import SnapKit
import RxSwift
import netfox

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let appDisposeBag = DisposeBag()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        self.initializeKakaoSDK()
        self.initializeLogger()
        self.initializeFirebase()
        self.initializeNotification(application: application)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    private func initializeKakaoSDK() {
        KakaoSDK.initSDK(appKey: Bundle.kakaoAppKey)
    }
    
    private func initializeLogger() {
        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.level = .debug
        
        #if DEBUG
        // netfox
        NFX.sharedInstance().setGesture(.custom)
        NFX.sharedInstance().start()
        #endif
    }
    
    private func initializeFirebase() {
        FirebaseApp.configure()
    }
    
    private func initializeNotification(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        
        if let pushTypeString = userInfo["pushOptions"] as? String {
            switch PushType(rawValue: pushTypeString) {
            case .background:
                self.renewStore()
                
                completionHandler([])
                
            case .push:
                completionHandler([[.sound, .banner]])
                
            case .unknown:
                completionHandler([])
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if let pushTypeString = userInfo["pushOptions"] as? String {
            switch PushType(rawValue: pushTypeString) {
            case .background:
                self.renewStore()
                
                completionHandler(.noData)
                
            case .push:
                completionHandler(UIBackgroundFetchResult.newData)
                
            case .unknown:
                completionHandler(.failed)
            }
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        if let deepLink = userInfo["link"] as? String {
            DeepLinkHandler.shared.handle(deepLink)
        }
    }
    
    private func renewStore() {
        let storeId = Preference.shared.storeId
        guard !storeId.isEmpty else {
            print("❌ 가게가 영업중인 상태가 아닙니다.")
            return
        }
        LocationManager.shared.getCurrentLocation()
            .flatMap { location -> Observable<String> in
                return StoreService().renewStore(storeId: storeId, location: location)
            }
            .subscribe(onNext: { _ in
                print("🙆🏻‍♂️ 가게 영업정보 갱신 완료")
            }, onError: { error in
                print("가게 정보 업데이트 에러:\(error)")
            })
            .disposed(by: self.appDisposeBag)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Preference.shared.fcmToken = fcmToken
        
        Task {
            guard let fcmToken else { return }
            _ = await DeviceRepositoryImpl().registerDevice(fcmToken: fcmToken)
        }
    }
}
