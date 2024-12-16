import UIKit
import PhotosUI

import PermissionsKit
import PhotoLibraryPermission
import CameraPermission
import CropViewController

protocol EditStoreInfoCoordinator: AnyObject, BaseCoordinator {
    func showPhotoActionSheet()
    
    func showCamera()
    
    func showAlbumPicker()
    
    func presentPhotoCrop(photo: UIImage)
}

extension EditStoreInfoCoordinator where Self: BaseViewController {
    func showPhotoActionSheet() {
        let alert = UIAlertController(
            title: "이미지 불러오기",
            message: nil,
            preferredStyle: .actionSheet
        )
        let libraryAction = UIAlertAction(
            title: "앨범",
            style: .default
        ) { [weak self] _ in
            guard let self else { return }
            if Permission.photoLibrary.authorized {
                self.showAlbumPicker()
            } else {
                PermissionManager.requestPhotoLibrary(viewController: self) {
                    self.showAlbumPicker()
                }
            }
        }
        let cameraAction = UIAlertAction(
            title: "카메라",
            style: .default
        ) { [weak self] _ in
            guard let self else { return }
            if Permission.camera.authorized {
                self.showCamera()
            } else {
                PermissionManager.requestCamera(viewController: self) {
                    self.showCamera()
                }
            }
        }
        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(libraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        self.presenter.present(alert, animated: true)
    }
    
    func showCamera() {
        let imagePicker = UIImagePickerController().then {
            $0.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            $0.sourceType = .camera
            $0.cameraCaptureMode = .photo
        }
        
        self.presenter.present(imagePicker, animated: true)
    }
    
    func showAlbumPicker() {
        var configuration = PHPickerConfiguration()
        
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        
        picker.delegate = self as? PHPickerViewControllerDelegate
        self.presenter.present(picker, animated: true, completion: nil)
    }
    
    func presentPhotoCrop(photo: UIImage) {
        let cropViewController = CropViewController(image: photo)
        
        cropViewController.customAspectRatio = CGSize(width: 2.227, height: 1)
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.resetButtonHidden = true
        cropViewController.delegate = self as? CropViewControllerDelegate
        self.present(cropViewController, animated: true, completion: nil)
    }
}
