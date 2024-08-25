import UIKit

final class DividerView: BaseView {
    let dividerView = UIView()
    
    override func setup() {
        setupLayout()
        setupDottedBorder()
    }
    
    private func setupLayout() {
        addSubview(dividerView)
        dividerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(1)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(1)
        }
    }
    
    private func setupDottedBorder() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.gray30.cgColor
        shapeLayer.lineDashPattern = [4, 4]
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = 1
        
        let path = UIBezierPath(rect: bounds)
        shapeLayer.path = path.cgPath
        
        dividerView.layer.addSublayer(shapeLayer)
        
        // 레이어가 크기에 맞게 조정되도록 자동 레이아웃 활성화
        shapeLayer.frame = dividerView.bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 레이아웃이 변경될 때마다 경로를 업데이트
        if let shapeLayer = dividerView.layer.sublayers?.first as? CAShapeLayer {
            let path = UIBezierPath(rect: dividerView.bounds)
            shapeLayer.path = path.cgPath
            shapeLayer.frame = dividerView.bounds
        }
    }
}
