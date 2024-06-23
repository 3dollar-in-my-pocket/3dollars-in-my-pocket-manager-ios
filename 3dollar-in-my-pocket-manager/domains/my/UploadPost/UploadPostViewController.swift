import UIKit
import Combine
import PhotosUI

final class UploadPostViewController: UIViewController {
    private let uploadPostView = UploadPostView()
    private let viewModel: UploadPostViewModel
    private var photoDataSource: [ImageContent] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: UploadPostViewModel = UploadPostViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = uploadPostView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    private func setup() {
        uploadPostView.imageCollectionView.register([
            UploadPhotoCell.self,
            PostPhotoCell.self
        ])
        uploadPostView.imageCollectionView.dataSource = self
        uploadPostView.imageCollectionView.delegate = self
        uploadPostView.textView.delegate = self
    }
    
    
    private func bind() {
        uploadPostView.backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        uploadPostView.uploadButton.addTarget(self, action: #selector(didTapUpload), for: .touchUpInside)
        
        viewModel.output.photos
            .main
            .sink { [weak self] imageContents in
                self?.photoDataSource = imageContents
                self?.uploadPostView.imageCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.output.message
            .first()
            .main
            .sink { [weak self] message in
                self?.uploadPostView.setMessage(message)
            }
            .store(in: &cancellables)
        
        viewModel.output.isEnableSaveButton
            .main
            .sink { [weak self] isEnable in
                self?.uploadPostView.setUploadButtonEnable(isEnable)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .sink { [weak self] route in
                switch route {
                case .presentPhotoPicker(let count):
                    self?.presentPhotoPicker(count: count)
                case .pop:
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapUpload() {
        viewModel.input.didTapUpload.send(())
    }
    
    private func presentPhotoPicker(count: Int) {
        guard count > 0 else { return }
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = count
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension UploadPostViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoDataSource.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell: UploadPhotoCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
            cell.bind(count: photoDataSource.count)
            return cell
        } else {
            guard let imageContent = photoDataSource[safe: indexPath.item - 1] else  {
                let cell: UICollectionViewCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                return cell
            }
            
            let cell: PostPhotoCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
            cell.bind(imageContent: imageContent) { [weak self] in
                self?.viewModel.input.didTapDeletePhoto.send(indexPath.item - 1)
            }
            return cell
        }
    }
}

extension UploadPostViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            viewModel.input.didTapUploadPhoto.send(())
        }
    }
}

extension UploadPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        var loadedImagesCount = 0
        var loadedImages = [UIImage](repeating: UIImage(), count: results.count)
        
        for (index, result) in results.enumerated() {
            let provider = result.itemProvider
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            loadedImages[index] = image
                            loadedImagesCount += 1
                            
                            if loadedImagesCount == results.count {
                                self?.viewModel.input.didSelectPhotos.send(loadedImages)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension UploadPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "upload_post.contents.placeholder".localizable {
            textView.text = ""
            textView.textColor = .gray100
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "upload_post.contents.placeholder".localizable
            textView.textColor = .gray30
        } else {
            viewModel.input.inputContents.send(textView.text)
        }
    }
}
