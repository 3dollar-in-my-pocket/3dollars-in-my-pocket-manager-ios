import UIKit
import PhotosUI

import SPPermissions
import CombineCocoa

final class EditMenuViewController: BaseViewController {
    private let viewModel: EditMenuViewModel
    private let editMenuView = EditMenuView()
    
    /// 메뉴 사진 클릭 시, 선택한 메뉴 인덱스 저장용
    private var selectedMenuIndex: Int?
    
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    init(viewModel: EditMenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = editMenuView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    private func bind() {
        // Input
        editMenuView.backButton.tapPublisher
            .subscribe(viewModel.input.didTapBack)
            .store(in: &cancellables)
        
        editMenuView.headerView.deleteButton.tapPublisher
            .subscribe(viewModel.input.didTapDelete)
            .store(in: &cancellables)
        
        editMenuView.addMenuButton.tapPublisher
            .subscribe(viewModel.input.didTapAddMenu)
            .store(in: &cancellables)
        
        editMenuView.saveButton.tapPublisher
            .subscribe(viewModel.input.didTapSave)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.menus
            .main
            .withUnretained(self)
            .sink { (owner: EditMenuViewController, menus: [BossStoreMenu]) in
                var menuItemViews: [EditMenuItemView] = []
                for (index, menu) in menus.enumerated() {
                    let menuItemView = EditMenuItemView()
                    menuItemView.bind(menu: menu)
                    
                    menuItemView.cameraButton.tapPublisher
                        .main
                        .sink { _ in
                            owner.selectedMenuIndex = index
                            owner.showPhotoActionSheet()
                        }
                        .store(in: &menuItemView.cancellables)
                    
                    menuItemView.menuNameTextField.textPublisher
                        .compactMap { $0 }
                        .map { name in
                            return (index: index, name: name)
                        }
                        .subscribe(owner.viewModel.input.inputMenuName)
                        .store(in: &menuItemView.cancellables)
                    
                    menuItemView.menuPriceTextField.textPublisher
                        .compactMap { $0 }
                        .map { price in
                            return (index: index, price: Int(price) ?? 0)
                        }
                        .subscribe(owner.viewModel.input.inputMenuPrice)
                        .store(in: &menuItemView.cancellables)
                    
                    menuItemView.deleteButon.tapPublisher
                        .map { index }
                        .subscribe(owner.viewModel.input.didTapDeleteMenu)
                        .store(in: &menuItemView.cancellables)
                    
                    owner.viewModel.output.showWarning
                        .main
                        .sink { (warningIndex: Int) in
                            let isShow = index == warningIndex
                            menuItemView.showWarning(isShow)
                        }
                        .store(in: &menuItemView.cancellables)
                    
                    owner.viewModel.output.isDeleteMode
                        .first()
                        .main
                        .sink { (isDeleteMode: Bool) in
                            menuItemView.setDeleteMode(isDeleteMode, animated: false)
                        }
                        .store(in: &menuItemView.cancellables)
                    
                    owner.viewModel.output.isDeleteMode
                        .dropFirst()
                        .main
                        .sink { (isDeleteMode: Bool) in
                            menuItemView.setDeleteMode(isDeleteMode, animated: true)
                        }
                        .store(in: &menuItemView.cancellables)
                    
                    menuItemViews.append(menuItemView)
                }
                
                owner.editMenuView.bind(menuItemViews: menuItemViews)
                owner.editMenuView.headerView.setMenuCount(menus.count)
            }
            .store(in: &cancellables)
        
        viewModel.output.isEnableSaveButton
            .main
            .withUnretained(self)
            .sink { (owner: EditMenuViewController, isEnable: Bool) in
                owner.editMenuView.setSaveButtonEnable(isEnable)
            }
            .store(in: &cancellables)
        
        viewModel.output.isDeleteMode
            .main
            .withUnretained(self)
            .sink { (owner: EditMenuViewController, isDeleteMode: Bool) in
                owner.editMenuView.setDeleteMode(isDeleteMode: isDeleteMode)
            }
            .store(in: &cancellables)
        
        viewModel.output.showLoading
            .main
            .sink { (isShow: Bool) in
                LoadingManager.shared.showLoading(isShow: isShow)
            }
            .store(in: &cancellables)
        
        viewModel.output.toast
            .main
            .sink { (message: String) in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: EditMenuViewController, route: EditMenuViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
}

// MARK: Route
extension EditMenuViewController {
    private func handleRoute(_ route: EditMenuViewModel.Route) {
        switch route {
        case .pop:
            navigationController?.popViewController(animated: true)
        case .showSaveAlert:
            showSaveAlert()
        case .showDeleteAllAlert:
            showDeleteAllAlert()
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
    
    private func showSaveAlert() {
        AlertUtils.showWithCancel(
            viewController: self,
            title: nil,
            message: "edit_menu_save_alert_message".localized,
            okButtonTitle: "edit_menu_save_alert_ok".localized
        ) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func showDeleteAllAlert() {
        AlertUtils.showWithCancel(
            viewController: self,
            title: nil,
            message: "edit_menu_delete_all_message".localized,
            okButtonTitle: "edit_menu_delete".localized
        ) { [weak self] in
            self?.viewModel.input.didTapDeleteAll.send(())
        }
    }
    
    private func showPhotoActionSheet() {
        let alert = UIAlertController(
            title: "common.load_image".localized,
            message: nil,
            preferredStyle: .actionSheet
        )
        let libraryAction = UIAlertAction(
            title: "common.album".localized,
            style: .default
        ) { _ in
            if SPPermissions.Permission.photoLibrary.authorized {
                self.showAlbumPicker()
            } else {
                let controller = SPPermissions.native([.photoLibrary])
                
                controller.delegate = self
                controller.present(on: self)
            }
        }
        let cameraAction = UIAlertAction(
            title: "common.camera".localized,
            style: .default
        ) { _ in
            if SPPermissions.Permission.camera.authorized {
                self.showCamera()
            } else {
                let controller = SPPermissions.native([.camera])
                
                controller.delegate = self
                controller.present(on: self)
            }
        }
        let cancelAction = UIAlertAction(
            title: "common.cancel".localized,
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(libraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        
        present(imagePicker, animated: true)
    }
    
    private func showAlbumPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension EditMenuViewController:
    UIImagePickerControllerDelegate & UINavigationControllerDelegate
{
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true, completion: nil)
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let selectedMenuIndex else { return }
            viewModel.input.addPhoto.send((selectedMenuIndex, photo))
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension EditMenuViewController: SPPermissionsDelegate {
    func didAllowPermission(_ permission: SPPermissions.Permission) {
        if permission == .camera {
            showCamera()
        } else if permission == .photoLibrary {
            showAlbumPicker()
        }
    }
    
    func didDeniedPermission(_ permission: SPPermissions.Permission) {
        AlertUtils.showWithCancel(
            viewController: self,
            title: "authorization_denied_title".localized,
            message: "authorization_denied_description".localized,
            okButtonTitle: "authorization_setting".localized
        ) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

extension EditMenuViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
            guard let self, let photo = image as? UIImage, let selectedMenuIndex else { return }
            viewModel.input.addPhoto.send((selectedMenuIndex, photo))
        }
    }
}
