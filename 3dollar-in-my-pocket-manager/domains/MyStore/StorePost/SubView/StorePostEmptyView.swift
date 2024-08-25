import UIKit

final class StorePostEmptyView: BaseView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "img_empty_post")
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.font = .extraBold(size: 18)
        label.textColor = .gray95
        label.attributedText = makeAttributedString()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override func setup() {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.width.equalTo(208)
            $0.height.equalTo(108)
            $0.top.equalToSuperview().offset(60)
            $0.centerX.equalToSuperview()
        }
        
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(36)
        }
    }
    
    private func makeAttributedString() -> NSMutableAttributedString {
        let string = "다양한 우리 가게의\n새로운 소식을 알려보세요!"
        let attributedString = NSMutableAttributedString(string: string)
        let range = NSString(string: string).range(of: "store_post.empty.title.bold".localizable)
        
        attributedString.addAttributes([.foregroundColor: UIColor.green], range: range)
        return attributedString
    }
}
