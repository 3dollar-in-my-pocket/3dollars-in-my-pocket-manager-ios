import UIKit

import KakaoSDKAuth
import netfox

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    static var shared: SceneDelegate? {
        UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
    }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        #if DEBUG
        window = ShakeDetectingWindow(frame: windowScene.coordinateSpace.bounds)
        #else
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        #endif
        window?.windowScene = windowScene
        window?.rootViewController = SplashViewController(viewModel: SplashViewModel())
        window?.makeKeyAndVisible()
        
        reserveDeepLinkIfExisted(connectionOptions: connectionOptions)
        reserveNotificationDeepLinkIfExisted(connectionOptions: connectionOptions)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
            DeepLinkHandler.shared.handle(url.absoluteString)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func goToSignin() {
        self.window?.rootViewController = SigninViewController.instance()
        self.window?.makeKeyAndVisible()
    }
    
    func goToWaiting() {
        self.window?.rootViewController = WaitingViewController.instance()
        self.window?.makeKeyAndVisible()
    }

    func goToMain() {
        let mainTabViewController = MainTabController(viewModel: MainViewModel())
        let navigationController = UINavigationController(rootViewController: mainTabViewController)
        navigationController.isNavigationBarHidden = true
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    private func reserveDeepLinkIfExisted(connectionOptions: UIScene.ConnectionOptions) {
        guard let url = connectionOptions.urlContexts.first?.url else { return }
        
        DeepLinkHandler.shared.handle(url.absoluteString)
    }
    
    private func reserveNotificationDeepLinkIfExisted(connectionOptions: UIScene.ConnectionOptions) {
        guard let userInfo = connectionOptions.notificationResponse?.notification.request.content.userInfo,
              let deepLink = userInfo["link"] as? String else { return }
        DeepLinkHandler.shared.handle(deepLink)
    }
}

extension SceneDelegate {
    final class ShakeDetectingWindow: UIWindow {
        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
                notificationFeedbackGenerator.prepare()
                notificationFeedbackGenerator.notificationOccurred(.success)
                NFX.sharedInstance().show()
            }
            super.motionEnded(motion, with: event)
        }
    }
}
