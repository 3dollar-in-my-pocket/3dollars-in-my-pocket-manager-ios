import UIKit
import SwiftUI

final class StoreNoticeViewController: UIHostingController<StorePostView> {
    private let storePostView = StorePostView()
    init() {
        super.init(rootView: storePostView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
