import UIKit
import SwiftUI
import Combine

final class StoreNoticeViewController: UIHostingController<StorePostView> {
    private var storePostView: StorePostView
    private var viewModel: StorePostViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let viewModel = StorePostViewModel()
        
        storePostView = StorePostView(viewModel: viewModel)
        self.viewModel = viewModel
        
        super.init(rootView: storePostView)
        
        bind()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        guard let viewModel else { return }
        
        viewModel.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                switch route {
                case .pushUpload:
                    self?.pushUploadPost()
                case .pushEdit(let viewModel):
                    self?.pushEditPost(viewModel: viewModel)
                }
            }
            .store(in: &cancellables)
    }
    
    private func pushUploadPost() {
        let viewController = UploadPostViewController()
        viewController.hidesBottomBarWhenPushed = true
        
        let parentViewController = parent
        let navigationController = parentViewController?.navigationController
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushEditPost(viewModel: UploadPostViewModel) {
        let viewController = UploadPostViewController(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
