import Foundation

import Base

final class SignInViewController: BaseViewController {
    private let signInView = SignInView()
    
    static func instance() -> SignInViewController {
        return SignInViewController(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = self.signInView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
