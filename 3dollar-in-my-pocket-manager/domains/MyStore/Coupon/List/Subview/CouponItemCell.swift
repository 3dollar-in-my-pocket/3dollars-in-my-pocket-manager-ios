import UIKit
import SnapKit

final class CouponItemCell: BaseCollectionViewCell {

    private static let sharedCell = CouponItemCell()
    
    enum Layout {
        static func size(width: CGFloat, viewModel: CouponItemCellViewModel) -> CGSize {
            
            sharedCell.bind(viewModel)
            
            let size: CGSize = .init(width: width, height: UIView.layoutFittingCompressedSize.height)
            let cellSize = sharedCell.systemLayoutSizeFitting(
                size,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            return cellSize
        }
    }
    
    // MARK: - UI
    private let container = UIView()
    
    private let badgeLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 4, bottomInset: 3, leftInset: 8, rightInset: 8)
        label.font = .bold(size: 12)
        return label
    }()
    
    private let closeCouponButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = Assets.icArrowRight.image
            .withTintColor(.gray50)
        
        let style = NSMutableParagraphStyle()
        config.attributedTitle = AttributedString("발급 중지하기", attributes: .init([
            .font: UIFont.medium(size: 12) as Any,
            .foregroundColor: UIColor.gray50,
            .paragraphStyle: style
        ]))
        config.imagePlacement = .trailing
        config.imagePadding = -2
        config.contentInsets = .zero
        let button = UIButton(configuration: config)
        return button
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .bold(size: 16)
        l.textColor = .gray95
        l.numberOfLines = 2
        return l
    }()

    private let periodLabel: UILabel = {
        let l = UILabel()
        l.font = .medium(size: 14)
        l.textColor = .gray60
        return l
    }()

    private let dashed = UIView()
    
    private let gridContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        return view
    }()
    private let grid = UIStackView()

    private let possibleTitle = CouponItemCell.makeMetricTitle("발급 가능 수량")
    private let issuedTitle   = CouponItemCell.makeMetricTitle("발급된 수량")
    private let usedTitle     = CouponItemCell.makeMetricTitle("사용 완료 수량")

    private let possibleCountLabel = CouponItemCell.makeMetricValue()
    private let issuedCountLabel   = CouponItemCell.makeMetricValue(highlight: true)
    private let usedCountLabel     = CouponItemCell.makeMetricValue()

    private let footerTipLabel: UILabel = {
        let l = UILabel()
        l.text = "* 최대 1개의 쿠폰만 만들 수 있습니다."
        l.font = .medium(size: 12)
        l.textColor = .gray50
        l.isHidden = true
        return l
    }()

    private var viewModel: CouponItemCellViewModel?
    
    override func setup() {
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(12)
        }

        let topRow = UIView()
        container.addSubview(topRow)

        topRow.addSubview(badgeLabel)
        topRow.addSubview(closeCouponButton)

        closeCouponButton.addTarget(self, action: #selector(didTapCloseCouponButton), for: .touchUpInside)

        container.addSubview(titleLabel)
        container.addSubview(periodLabel)
        container.addSubview(dashed)

        // Grid (3 columns)
        grid.axis = .horizontal
        grid.distribution = .fillEqually
        grid.alignment = .fill
        grid.spacing = 0

        let col1 = makeMetricColumn(title: possibleTitle, value: possibleCountLabel)
        let col2 = makeMetricColumn(title: issuedTitle, value: issuedCountLabel)
        let col3 = makeMetricColumn(title: usedTitle, value: usedCountLabel)
        [col1, col2, col3].forEach { grid.addArrangedSubview($0) }

        container.addSubview(gridContainer)
        gridContainer.addSubview(grid)
        contentView.addSubview(footerTipLabel)

        // Constraints
        topRow.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(14)
            make.height.greaterThanOrEqualTo(24)
        }

        badgeLabel.layer.cornerRadius = 12
        badgeLabel.clipsToBounds = true
        badgeLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.height.equalTo(24)
        }

        closeCouponButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(badgeLabel)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(topRow.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(14)
        }

        periodLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(14)
        }

        dashed.snp.makeConstraints { make in
            make.top.equalTo(periodLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }

        gridContainer.snp.makeConstraints { make in
            make.top.equalTo(dashed.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(64)
        }
        
        grid.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        footerTipLabel.snp.makeConstraints { make in
            make.top.equalTo(container.snp.bottom).offset(12)
            make.leading.trailing.equalTo(container).inset(4)
        }
    }


    func bind(_ viewModel: CouponItemCellViewModel) {
        self.viewModel = viewModel
        
        let model = viewModel.output.coupon
        titleLabel.text = model.name
        periodLabel.text = "사용 기간  |  \(formatDay(model.validityPeriod.startDateTime)) ~ \(formatDay(model.validityPeriod.endDateTime))"

        possibleCountLabel.text = "\(model.maxIssuableCount)"
        issuedCountLabel.text = "\(model.currentIssuedCount)"
        usedCountLabel.text = "\(model.currentUsedCount)"

        // 상태 스타일 및 UI
        switch model.status {
        case .ended:
            applyEndedStyle()
            closeCouponButton.isHidden = true
            footerTipLabel.isHidden = true
        case .active:
            applyActiveStyle()
            closeCouponButton.isHidden = false
            footerTipLabel.isHidden = false
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        dashed.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        footerTipLabel.isHidden = true
        closeCouponButton.isHidden = true
    }

    // MARK: - Styles
    private func applyBaseAppearance(borderColor: UIColor, shadow: Bool, badgeText: String, badgeBG: UIColor, badgeFG: UIColor) {
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = borderColor.cgColor
        contentView.backgroundColor = .clear
        if shadow {
            container.layer.shadowColor = UIColor.green.cgColor
            container.layer.shadowOpacity = 0.08
            container.layer.shadowRadius = 16
            container.layer.shadowOffset = CGSize(width: 0, height: 6)
        } else {
            container.layer.shadowOpacity = 0
        }

        badgeLabel.text = badgeText
        badgeLabel.backgroundColor = badgeBG
        badgeLabel.textColor = badgeFG

        // dashed divider
        drawDashed()
    }

    private func applyEndedStyle() {
        applyBaseAppearance(borderColor: .gray40, shadow: false,
                            badgeText: "사용 종료", badgeBG: .gray50, badgeFG: .white)
        possibleCountLabel.textColor = .gray60
        issuedCountLabel.textColor = .gray60
        usedCountLabel.textColor = .gray60
        container.layer.shadowOpacity = 0
        gridContainer.backgroundColor = .gray10
    }

    private func applyPausedUsableStyle() {
        applyBaseAppearance(borderColor: .green100, shadow: false,
                            badgeText: "발급 중지 / 사용 가능", badgeBG: .green100, badgeFG: .green)
        issuedCountLabel.textColor = UIColor.green
        gridContainer.backgroundColor = .green100
    }

    private func applyActiveStyle() {
        applyBaseAppearance(borderColor: .green, shadow: true,
                            badgeText: "발급 중", badgeBG: .green, badgeFG: .white)
        issuedCountLabel.textColor = UIColor.green
        gridContainer.backgroundColor = .green100
    }
    
    
    static func makeMetricTitle(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .medium(size: 12)
        l.textColor = .gray60
        l.textAlignment = .center
        return l
    }

    static func makeMetricValue(highlight: Bool = false) -> UILabel {
        let l = UILabel()
        l.font = .semiBold(size: 14)
        l.textColor = highlight ? UIColor.green : .gray95
        l.textAlignment = .center
        return l
    }

    func makeMetricColumn(title: UILabel, value: UILabel) -> UIStackView {
        let v = UIStackView(arrangedSubviews: [title, value])
        v.axis = .vertical
        v.alignment = .center
        v.spacing = 2
        return v
    }

    func drawDashed() {
        dashed.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let layer = CAShapeLayer()
        switch viewModel?.output.coupon.status {
        case .ended, .none:
            layer.strokeColor = UIColor.gray50.cgColor
        case .active:
            layer.strokeColor = UIColor.green.cgColor
        }
        
        layer.lineDashPattern = [4, 4]
        layer.lineWidth = 1
        layer.fillColor = UIColor.clear.cgColor
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0.5))
        path.addLine(to: CGPoint(x: bounds.width - 48, y: 0.5))
        layer.path = path.cgPath
        layer.frame = dashed.bounds
        dashed.layer.addSublayer(layer)
    }

    internal override func layoutSubviews() {
        super.layoutSubviews()
        drawDashed()
    }
}

// MARK: - Helpers
private extension CouponItemCell {
    @objc func didTapCloseCouponButton() {
        viewModel?.input.didTapClose.send()
    }

    func formatDay(_ iso: String) -> String {
        // Try ISO8601 first, fallback to common server formats
        let f1 = ISO8601DateFormatter()
        f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f1.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) {
            let out = DateFormatter()
            out.locale = Locale(identifier: "ko_KR")
            out.timeZone = TimeZone.current
            out.dateFormat = "yyyy.MM.dd"
            return out.string(from: d)
        }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let d = f.date(from: iso) {
            let out = DateFormatter()
            out.locale = Locale(identifier: "ko_KR")
            out.timeZone = TimeZone.current
            out.dateFormat = "yyyy.MM.dd"
            return out.string(from: d)
        }
        return iso
    }
}
