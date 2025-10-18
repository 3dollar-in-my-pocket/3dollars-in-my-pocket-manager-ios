import UIKit
import SnapKit

final class CouponRegisterAlertViewController: UIViewController {

    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?

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
        l.text = "쿠폰 발급을 시작할까요?"
        l.textAlignment = .center
        l.font = .semiBold(size: 20)
        l.textColor = .gray100
        l.numberOfLines = 0
        return l
    }()

    private let guideBox = UIView()

    private let cautionLabel: UILabel = {
        let l = UILabel()
        l.text = "*고객이 정당하게 발급받은 쿠폰을 사장님이 임의로\n거부할 경우, 앱 이용에 제재가 있을 수 있습니다."
        l.textColor = .red
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = .semiBold(size: 14)
        return l
    }()

    private let helperLabel: UILabel = {
        let l = UILabel()
        l.text = "쿠폰 사용이 원활히 이루어질 수 있도록 도와주세요!"
        l.textColor = UIColor.gray50
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = .medium(size: 12)
        return l
    }()

    private let confirmButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("발급 시작하기", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor.green
        b.layer.cornerRadius = 8
        b.titleLabel?.font = .bold(size: 14)
        return b
    }()

    private let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("취소", for: .normal)
        b.setTitleColor(UIColor.green, for: .normal)
        b.backgroundColor = .clear
        b.layer.cornerRadius = 8
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.green.cgColor
        b.titleLabel?.font = .bold(size: 14)
        return b
    }()

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

    // MARK: Present Helper
    static func present(from presenter: UIViewController,
                        onConfirm: (() -> Void)? = nil,
                        onCancel: (() -> Void)? = nil) {
        let vc = CouponRegisterAlertViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.onConfirm = onConfirm
        vc.onCancel = onCancel
        presenter.present(vc, animated: false, completion: nil)
    }
}

// MARK: - Layout & Content
private extension CouponRegisterAlertViewController {
    func layout() {
        view.addSubview(dimView)
        view.addSubview(container)
        dimView.snp.makeConstraints { $0.edges.equalToSuperview() }

        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Title
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        // Guide Box
        guideBox.backgroundColor = .gray5
        guideBox.layer.cornerRadius = 10
        container.addSubview(guideBox)
        guideBox.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Rows inside guide box
        let rows: [(String, String)] = [
            ("👀", "쿠폰은 발급과 동시에 고객 앱에 노출돼요."),
            ("⏰", "고객은 설정한 사용 기간 동안 쿠폰을 사용할 수 있어요."),
            ("⚠️", "한 번 발급하면, 사용 기간은 수정할 수 없습니다."),
            ("✅", "꼭 내용을 다시 한 번 확인해주세요!")
        ]

        var previous: UIView? = nil
        for (icon, text) in rows {
            let row = makeRow(icon: icon, text: text)
            guideBox.addSubview(row)
            row.snp.makeConstraints { make in
                if let prev = previous {
                    make.top.equalTo(prev.snp.bottom).offset(8)
                } else {
                    make.top.equalToSuperview().inset(12)
                }
                make.leading.trailing.equalToSuperview().inset(16)
            }
            previous = row
        }
        if let last = previous {
            last.snp.makeConstraints { make in
                make.bottom.equalToSuperview().inset(12)
            }
        }

        // Caution & Helper
        container.addSubview(cautionLabel)
        container.addSubview(helperLabel)
        cautionLabel.snp.makeConstraints { make in
            make.top.equalTo(guideBox.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        helperLabel.snp.makeConstraints { make in
            make.top.equalTo(cautionLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Buttons
        container.addSubview(confirmButton)
        container.addSubview(cancelButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(helperLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(confirmButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    func makeRow(icon: String, text: String) -> UIView {
        let v = UIView()
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .medium(size: 14)
        iconLabel.setContentHuggingPriority(.required, for: .horizontal)
        iconLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let textLabel = UILabel()
        textLabel.text = text
        textLabel.numberOfLines = 0
        textLabel.font = .medium(size: 14)
        textLabel.textColor = .gray50

        v.addSubview(iconLabel)
        v.addSubview(textLabel)
        iconLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconLabel.snp.trailing).offset(6)
            make.top.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return v
    }
}

// MARK: - Bind & Actions
private extension CouponRegisterAlertViewController {
    func bind() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(tap)

        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    @objc func dimTapped() { dismissAnimated(trigger: .cancel) }
    @objc func cancelTapped() { dismissAnimated(trigger: .cancel) }
    @objc func confirmTapped() { dismissAnimated(trigger: .confirm) }

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
            self.dismiss(animated: false) {
                switch trigger {
                case .confirm: self.onConfirm?()
                case .cancel: self.onCancel?()
                }
            }
        }
    }
}
