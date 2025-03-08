import UIKit

final class StarBadgeView: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        axis = .horizontal
        spacing = 0
        layoutMargins = .init(top: 4, left: 4, bottom: 4, right: 4)
        isLayoutMarginsRelativeArrangement = true
        backgroundColor = .pink100
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }
    
    func bind(rating: Int) {
        clearStack()
        
        for index in 0..<5 {
            let starImageView = UIImageView(image: Assets.icStarSolid.image.withRenderingMode(.alwaysTemplate))
            let tintColor: UIColor = index < rating ? .pink : .pink200
            starImageView.tintColor = tintColor
            starImageView.snp.makeConstraints {
                $0.size.equalTo(12)
            }
            
            addArrangedSubview(starImageView)
        }
    }
    
    private func clearStack() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}
