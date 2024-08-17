import UIKit
import PhotosUI

import CombineCocoa
import SPPermissions

final class EditStoreInfoViewController: BaseViewController {
    private let editStoreInfoView = EditStoreInfoView()
    private let viewModel: EditStoreInfoViewModel
    private var photoLimit: Int?
    
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    init(viewModel: EditStoreInfoViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = editStoreInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        editStoreInfoView.categoryCollectionView.collectionView.delegate = self
        editStoreInfoView.photoView.collectionView.delegate = self
        viewModel.input.load.send(())
    }
    
    private func bind() {
        editStoreInfoView.backButton.tapPublisher
            .main
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        // Input
        editStoreInfoView.storeNameField.textField.textField.textPublisher
            .compactMap { $0 }
            .subscribe(viewModel.input.inputStoreName)
            .store(in: &cancellables)
        
        editStoreInfoView.snsField.textField.textField.textPublisher
            .compactMap { $0 }
            .subscribe(viewModel.input.inputSNS)
            .store(in: &cancellables)
        
        editStoreInfoView.photoView.didTapDeletePhoto
            .subscribe(viewModel.input.deletePhoto)
            .store(in: &cancellables)
        
        editStoreInfoView.saveButton.tapPublisher
            .subscribe(viewModel.input.didTapSave)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.store
            .combineLatest(viewModel.output.categories)
            .main
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewController, value: (BossStoreInfoResponse, [StoreFoodCategoryResponse])) in
                let (store, categories) = value
                owner.editStoreInfoView.bind(store: store, categories: categories)
            }
            .store(in: &cancellables)
        
        viewModel.output.isEnableSaveButton
            .removeDuplicates()
            .main
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewController, isEnable: Bool) in
                owner.editStoreInfoView.setSaveButtonEnable(isEnable)
            }
            .store(in: &cancellables)
        
        viewModel.output.toast
            .main
            .sink { message in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.showLoading
            .main
            .sink { (isShow: Bool) in
                LoadingManager.shared.showLoading(isShow: isShow)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: EditStoreInfoViewController, route: EditStoreInfoViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: EditStoreInfoViewModel.Route) {
        switch route {
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .pop:
            navigationController?.popViewController(animated: true)
        case .presentPhotoPicker(let limit):
            showPhotoActionSheet(limit: limit)
        }
    }
}

// MARK: Route
extension EditStoreInfoViewController {
    func showPhotoActionSheet(limit: Int) {
        let alert = UIAlertController(
            title: "common_load_image".localized,
            message: nil,
            preferredStyle: .actionSheet
        )
        let libraryAction = UIAlertAction(
            title: "common_album".localized,
            style: .default
        ) { [weak self] _ in
            guard let self else { return }
            if SPPermissions.Permission.photoLibrary.authorized {
                showAlbumPicker(limit: limit)
            } else {
                let controller = SPPermissions.native([.photoLibrary])
                
                photoLimit = limit
                controller.delegate = self
                controller.present(on: self)
            }
        }
        let cameraAction = UIAlertAction(
            title: "common_camera".localized,
            style: .default
        ) { [weak self] _ in
            guard let self else { return }
            if SPPermissions.Permission.camera.authorized {
                showCamera()
            } else {
                let controller = SPPermissions.native([.camera])
                
                controller.delegate = self
                controller.present(on: self)
            }
        }
        let cancelAction = UIAlertAction(
            title: "common_cancel".localized,
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(libraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func showCamera() {
        let imagePicker = UIImagePickerController().then {
            $0.delegate = self
            $0.sourceType = .camera
            $0.cameraCaptureMode = .photo
        }
        
        present(imagePicker, animated: true)
    }
    
    func showAlbumPicker(limit: Int) {
        var configuration = PHPickerConfiguration()
        
        configuration.filter = .images
        configuration.selectionLimit = limit
        
        let picker = PHPickerViewController(configuration: configuration)
        
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension EditStoreInfoViewController:
    UIImagePickerControllerDelegate & UINavigationControllerDelegate
{
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            viewModel.input.addPhotos.send([photo])
        }
    }
}

extension EditStoreInfoViewController: SPPermissionsDelegate {
    func didAllowPermission(_ permission: SPPermissions.Permission) {
        if permission == .camera {
            showCamera()
        } else if permission == .photoLibrary {
            let limit = photoLimit ?? EditStoreInfoViewModel.Constant.maxPhotoCount
            showAlbumPicker(limit: limit)
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

extension EditStoreInfoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard results.isNotEmpty else { return }
        
        var images = [UIImage]()
        let group = DispatchGroup()
        
        for result in results {
            group.enter()
            
            guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
                group.leave()
                continue
            }
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let image = image as? UIImage {
                    images.append(image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.viewModel.input.addPhotos.send(images)
        }
    }
}


extension EditStoreInfoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == editStoreInfoView.categoryCollectionView.collectionView {
            viewModel.input.selectCategory.send(indexPath.item)
        } else if collectionView == editStoreInfoView.photoView.collectionView && indexPath.item == 0 {
            viewModel.input.didTapAddPhoto.send(())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard collectionView == editStoreInfoView.categoryCollectionView.collectionView else { return }
        viewModel.input.deselectCategory.send(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard collectionView == editStoreInfoView.categoryCollectionView.collectionView else { return true }
        if let selectedCount = collectionView.indexPathsForSelectedItems?.count {
            return selectedCount < CategorySelectView.Constant.maxCategoryCount
        } else {
            return true
        }
    }
}
