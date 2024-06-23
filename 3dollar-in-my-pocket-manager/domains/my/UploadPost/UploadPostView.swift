import UIKit

final class UploadPostView: BaseView {
    let backgroundButton = UIButton()
    
    let backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "ic_back")?
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .gray100
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray100
        label.font = .medium(size: 16)
        label.text = "upload_post.title".localizable
        return label
    }()
    
    
    lazy var imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    
    let postLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray100
        label.font = .bold(size: 14)
        label.text = "upload_post.contents.title".localizable
        return label
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.textColor = .gray100
        textView.font = .medium(size: 14)
        textView.contentInset = .init(top: 15, left: 12, bottom: 15, right: 12)
        textView.backgroundColor = .gray5
        textView.layer.cornerRadius = 8
        return textView
    }()
    
    let uploadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray30
        button.setTitle("upload_post.save".localizable, for: .normal)
        button.titleLabel?.font = .medium(size: 16)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let buttonBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray30
        return view
    }()
    
    override func setup() {
        backgroundButton.addTarget(self, action: #selector(didTapBackground), for: .touchUpInside)
        backgroundColor = .white
        
        addSubview(backgroundButton)
        backgroundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.size.equalTo(24)
            $0.top.equalTo(safeAreaLayoutGuide).offset(21)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.centerX.equalToSuperview()
        }
        
        addSubview(imageCollectionView)
        imageCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(backButton.snp.bottom).offset(28)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(84)
        }
        
        addSubview(postLabel)
        postLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(imageCollectionView.snp.bottom).offset(24)
        }
        
        addSubview(textView)
        textView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(postLabel.snp.bottom).offset(8)
            $0.height.equalTo(240)
        }
        
        
        addSubview(uploadButton)
        uploadButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        addSubview(buttonBackgroundView)
        buttonBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(uploadButton.snp.bottom)
        }
    }
    
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = PostPhotoCell.Layout.size
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        return layout
    }
    
    func setUploadButtonEnable(_ isEnable: Bool) {
        let backgroundColor: UIColor = isEnable ? .green : .gray30
        uploadButton.backgroundColor = backgroundColor
        buttonBackgroundView.backgroundColor = backgroundColor
        uploadButton.isEnabled = isEnable
    }
    
    func setMessage(_ message: String) {
        if message.isEmpty {
            textView.text = "upload_post.contents.placeholder".localizable
            textView.textColor = .gray30
        } else {
            textView.text = message
            textView.textColor = .gray100
        }
    }
    
    
    @objc private func didTapBackground() {
        endEditing(true)
    }
}
