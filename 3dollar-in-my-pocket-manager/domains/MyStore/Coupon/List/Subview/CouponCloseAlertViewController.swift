import UIKit
import SnapKit

final class CouponCloseAlertViewController: UIViewController {
    var onConfirm: ((String) -> Void)?
    var onCancel: (() -> Void)?

    static func present(from presenter: UIViewController,
                        couponId: String,
                        onConfirm: ((String) -> Void)? = nil,
                        onCancel: (() -> Void)? = nil) {
        let vc = CouponCloseAlertViewController(couponId: couponId)
        vc.onConfirm = onConfirm
        vc.onCancel = onCancel
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        presenter.present(vc, animated: false)
    }

    // MARK: UI
    private let dimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        v.alpha = 0
        return v
    }()

    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.12
        v.layer.shadowRadius = 16
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "쿠폰 발급을 중지할까요?"
        l.textAlignment = .center
        l.font = .semiBold(size: 20)
        l.textColor = .gray100
        l.numberOfLines = 0
        return l
    }()

    private let guideBox: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.96, alpha: 1)
        v.layer.cornerRadius = 12
        return v
    }()

    private lazy var row1: UIView = makeRow(icon: "⚠️", text: "쿠폰 발급이 중지되면, 고객은 더 이상 새로 발급받을 수 없습니다.", color: .gray50)

    private lazy var row2: UIView =  makeRow(icon: "⚠️", text: "단, 이미 발급된 쿠폰은 사용 기간까지 정상적으로 사용할 수 있어요.", color: .red)

    private let cautionLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = .medium(size: 12)
        l.textColor = .gray60
        l.text = "*정당하게 발급된 쿠폰 사용을 거부하실 경우, 앱 이용에 제한이 있을 수 있으며, 그로 인한 불이익은 사장님께 책임이 있을 수 있습니다."
        l.setLineHeight(lineHeight: 18)
        return l
    }()

    private let checkButton: UIButton = {
        let b = UIButton()
        b.setImage(Assets.icCheckOff.image, for: .normal)
        b.setTitle(" 위의 내용을 모두 확인하였습니다.", for: .normal)
        b.titleLabel?.font = .semiBold(size: 14)
        b.setTitleColor(.gray60, for: .normal)
        b.contentHorizontalAlignment = .left
        return b
    }()

    private let confirmButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("발급 중지하기", for: .normal)
        b.titleLabel?.font = .bold(size: 14)
        b.layer.cornerRadius = 8
        b.setTitleColor(.white, for: .normal)
        return b
    }()

    private let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("취소", for: .normal)
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.gray50.cgColor
        b.titleLabel?.font = .bold(size: 14)
        b.layer.cornerRadius = 8
        b.setTitleColor(.gray50, for: .normal)
        return b
    }()

    private var isChecked: Bool = false {
        didSet { updateConfirmState() }
    }
    
    private let couponId: String

    init(couponId: String) {
        self.couponId = couponId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        layout()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
}

// MARK: - Layout
private extension CouponCloseAlertViewController {
    func layout() {
        view.addSubview(dimView)
        view.addSubview(container)
        dimView.snp.makeConstraints { $0.edges.equalToSuperview() }
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }

        container.addSubview(titleLabel)
        container.addSubview(guideBox)
        container.addSubview(cautionLabel)
        container.addSubview(checkButton)
        container.addSubview(confirmButton)
        container.addSubview(cancelButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        guideBox.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // rows inside guide box
        guideBox.addSubview(row1)
        guideBox.addSubview(row2)
        row1.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14)
            make.leading.trailing.equalToSuperview().inset(14)
        }
        row2.snp.makeConstraints { make in
            make.top.equalTo(row1.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(12)
        }

        cautionLabel.snp.makeConstraints { make in
            make.top.equalTo(guideBox.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        checkButton.snp.makeConstraints { make in
            make.top.equalTo(cautionLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(checkButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(confirmButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(20)
        }

        // initial disabled state
        updateConfirmState()
    }
}

// MARK: - Bind & Actions
private extension CouponCloseAlertViewController {
    func bind() {
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(dimTap)
        checkButton.addTarget(self, action: #selector(toggleCheck), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    @objc func dimTapped() { dismissAnimated(trigger: .cancel) }

    @objc func toggleCheck() {
        isChecked.toggle()
    }

    @objc func confirmTapped() {
        guard isChecked else { return }
        dismissAnimated(trigger: .confirm)
    }

    @objc func cancelTapped() { dismissAnimated(trigger: .cancel) }

    func updateConfirmState() {
        if isChecked {
            confirmButton.backgroundColor = .red
            confirmButton.isEnabled = true
            checkButton.setImage(Assets.icCheck.image, for: .normal)
        } else {
            confirmButton.backgroundColor = .gray40
            confirmButton.isEnabled = false
            checkButton.setImage(Assets.icCheckOff.image, for: .normal)
        }
    }
}

// MARK: - Animations
private extension CouponCloseAlertViewController {
    enum DismissTrigger { case confirm, cancel }

    func animateIn() {
        container.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        container.alpha = 0
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut]) {
            self.dimView.alpha = 1
            self.container.alpha = 1
            self.container.transform = .identity
        }
    }

    func dismissAnimated(trigger: DismissTrigger) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn]) {
            self.dimView.alpha = 0
            self.container.alpha = 0
            self.container.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        } completion: { _ in
            self.dismiss(animated: false) { [weak self] in
                guard let self else { return }
                
                switch trigger {
                case .confirm: onConfirm?(couponId)
                case .cancel: onCancel?()
                }
            }
        }
    }
}

// MARK: - Factory
private extension CouponCloseAlertViewController {
    func makeRow(icon: String, text: String, color: UIColor) -> UIView {
        let v = UIView()
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .semiBold(size: 14)
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.numberOfLines = 0
        textLabel.font = .semiBold(size: 14)
        textLabel.textColor = color
        v.addSubview(iconLabel)
        v.addSubview(textLabel)
        iconLabel.setContentHuggingPriority(.required, for: .horizontal)
        iconLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        iconLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconLabel.snp.trailing).offset(6)
            make.top.trailing.bottom.equalToSuperview()
        }
        return v
    }
}
