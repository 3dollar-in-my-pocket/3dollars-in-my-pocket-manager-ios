import UIKit

import Base
import RxSwift
import RxCocoa

final class PhotoUploadView: BaseView {
    enum ViewType {
        case signup
        case edit
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = .gray100
        $0.text = "signup_photo_title".localized
    }
    
    private let requiredDot = UIView().then {
        $0.backgroundColor = .pink
        $0.layer.cornerRadius = 2
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = .gray50
        $0.font = .regular(size: 14)
        $0.text = "signup_photo_description".localized
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .gray5
        $0.layer.cornerRadius = 8
    }
    
    fileprivate let imageView = UIImageView().then {
        $0.backgroundColor = UIColor(r: 236, g: 236, b: 236)
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    fileprivate let uploadButton = UIButton().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.setTitle("signup_upload_photo".localized, for: .normal)
        $0.setTitleColor(.green, for: .normal)
        $0.titleLabel?.font = .bold(size: 14)
        $0.layer.shadowColor = UIColor(r: 0, g: 198, b: 103).cgColor
        $0.layer.shadowOffset = CGSize(width: 4, height: 4)
        $0.layer.shadowOpacity = 0.1
    }
    
    init(type: ViewType) {
        super.init(frame: .zero)
        
        self.setType(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        self.addSubViews([
            self.titleLabel,
            self.requiredDot,
            self.descriptionLabel,
            self.containerView,
            self.imageView,
            self.uploadButton
        ])
    }
    
    override func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.requiredDot.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel.snp.right).offset(4)
            make.top.equalTo(self.titleLabel)
            make.width.height.equalTo(4)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(4)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(12)
            make.bottom.equalTo(self.uploadButton).offset(12)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(12)
            make.top.equalTo(self.containerView).offset(14)
            make.right.equalTo(self.containerView).offset(-12)
            make.height.equalTo(self.imageView.snp.width).dividedBy(2.227)
        }
        
        self.uploadButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(self.imageView.snp.bottom).offset(10)
            make.height.equalTo(48)
        }
        
        self.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel).priority(.high)
            make.bottom.equalTo(self.containerView).priority(.high)
        }
    }
    
    func setImage(imageUrl: String?) {
        self.imageView.setImage(urlString: imageUrl)
    }
    
    private func setType(type: ViewType) {
        switch type {
        case .signup:
            self.titleLabel.text = "signup_photo_title".localized
            self.descriptionLabel.text = "signup_photo_description".localized
            self.uploadButton.setTitle("signup_upload_photo".localized, for: .normal)
            
        case .edit:
            self.titleLabel.text = "edit_store_info_photo_title".localized
            self.descriptionLabel.text = nil
            self.uploadButton.setTitle("edit_store_info_upload_photo".localized, for: .normal)
        }
    }
}

extension Reactive where Base: PhotoUploadView {
    var tapUploadButton: ControlEvent<Void> {
        return base.uploadButton.rx.tap
    }
    
    var photo: Binder<UIImage?> {
        return Binder(self.base) { view, photo in
            if let photo = photo {
                view.imageView.image = photo
            } else {
                view.imageView.image = UIImage(named: "img_store_default")
            }
            
        }
    }
}
