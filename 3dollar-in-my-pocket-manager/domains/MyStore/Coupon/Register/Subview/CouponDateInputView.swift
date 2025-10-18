import UIKit
import SnapKit
import Combine

final class CouponDateInputView: UIView {

    let startDatePublisher = CurrentValueSubject<String, Never>("")
    let endDatePublisher   = CurrentValueSubject<String, Never>("")

    func configure(startDateText: String?, endDateText: String?) {
        startRow.setDateText(startDateText)
        endRow.setDateText(endDateText)
    }

    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "쿠폰 사용 기간"
        label.font = .bold(size: 16)
        label.textColor = .gray95
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = Self.makeDescriptionAttributedText()
        return label
    }()

    private let startRow = DateInputRow(title: "사용 시작일")
    private let endRow = DateInputRow(title: "사용 종료일")

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

// MARK: - Private
private extension CouponDateInputView {
    func setup() {
        backgroundColor = .clear

        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(startRow)
        addSubview(endRow)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        startRow.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.greaterThanOrEqualTo(48)
        }

        endRow.snp.makeConstraints { make in
            make.top.equalTo(startRow.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(48)
        }

        // Set default date texts
        startRow.setDateText(formatDate(Date()))
        if let endDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) {
            endRow.setDateText(formatDate(endDate))
        } else {
            endRow.setDateText(nil)
        }

        let today = Date()
        let startAPI = formatAPIDate(today, isEndDate: false)
        startDatePublisher.send(startAPI)
        if let endDate = Calendar.current.date(byAdding: .day, value: 30, to: today) {
            let endAPI = formatAPIDate(endDate, isEndDate: true)
            endDatePublisher.send(endAPI)
        }

        // Gestures
        let startTap = UITapGestureRecognizer(target: self, action: #selector(didTapStart))
        startRow.addGestureRecognizer(startTap)
        startRow.isUserInteractionEnabled = true

        let endTap = UITapGestureRecognizer(target: self, action: #selector(didTapEnd))
        endRow.addGestureRecognizer(endTap)
        endRow.isUserInteractionEnabled = true
    }

    @objc func didTapStart() {
        presentDatePicker(title: "사용 시작일", initialDate: Date()) { [weak self] selectedDate in
            guard let self = self else { return }
            let formatted = self.formatDate(selectedDate)
            self.startRow.setDateText(formatted)
            let apiString = self.formatAPIDate(selectedDate, isEndDate: false)
            self.startDatePublisher.send(apiString)
        }
    }
    @objc func didTapEnd() {
        presentDatePicker(
            title: "사용 종료일",
            initialDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())
        ) { [weak self] selectedDate in
            guard let self = self else { return }
            let formatted = self.formatDate(selectedDate)
            self.endRow.setDateText(formatted)
            let apiString = self.formatAPIDate(selectedDate, isEndDate: true)
            self.endDatePublisher.send(apiString)
        }
    }

    /// Presents a date picker in a bottom sheet modal.
    private func presentDatePicker(title: String, initialDate: Date?, completion: @escaping (Date) -> Void) {
        guard let topVC = self.topViewController() else { return }
        let sheetVC = DatePickerSheetViewController(title: title, initialDate: initialDate) { selectedDate in
            completion(selectedDate)
        }
        if let sheet = sheetVC.sheetPresentationController {
            if #available(iOS 15.0, *) {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
        } else {
            sheetVC.modalPresentationStyle = .formSheet
        }
        topVC.present(sheetVC, animated: true, completion: nil)
    }

    /// Formats a date as "yyyy. M. d EEEE" in Korean locale.
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy. M. d EEEE"
        return formatter.string(from: date)
    }
    
    /// Formats a date as API string in "yyyy-MM-dd'T'HH:mm:ss" at start of the day.
    private func formatAPIDate(_ date: Date, isEndDate: Bool) -> String {
        
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        if isEndDate {
            comps.hour = 23
            comps.minute = 59
            comps.second = 59
        }
        
        guard let endOfDay = Calendar.current.date(from: comps) else { return "" }
        
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return f.string(from: endOfDay)
    }

    /// Finds the top-most view controller in the window hierarchy.
    private func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseVC: UIViewController?
        if let base = base {
            baseVC = base
        } else {
            baseVC = UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first?.rootViewController
        }
        if let nav = baseVC as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = baseVC as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = baseVC?.presentedViewController {
            return topViewController(base: presented)
        }
        return baseVC
    }

    static func makeDescriptionAttributedText() -> NSAttributedString {
        let full = "이 기간 동안 쿠폰을 발급 받거나 사용할 수 있어요.\n종료일 전 발급 중지는 가능하지만, 이미 발급된 쿠폰은 유효합니다!\n사용 기간은 수정할 수 없습니다."
        let attr = NSMutableAttributedString(string: full)

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        attr.addAttributes([
            .font: UIFont.medium(size: 12) ?? .systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray50,
            .paragraphStyle: paragraph
        ], range: NSRange(location: 0, length: attr.length))

        if let range = (full as NSString).range(of: "이미 발급된 쿠폰은 유효").toOptional() {
            attr.addAttribute(.font, value: UIFont.bold(size: 12) ?? .systemFont(ofSize: 12), range: range)
            attr.addAttribute(.foregroundColor, value: UIColor.gray50, range: range)
        }
        return attr
    }
}

// MARK: - Row View
private final class DateInputRow: UIView {
    private let container = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 12)
        label.textColor = .gray60
        return label
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray30
        return view
    }()

    private let calendarIcon: UIImageView = {
        let iv = UIImageView(image: Assets.calendar.image)
        iv.tintColor = UIColor.gray95
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray95
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 1
        return label
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setDateText(_ text: String?) {
        dateLabel.text = text
    }

    private func setup() {
        // Background style as screenshot (light gray rounded box)
        container.backgroundColor = UIColor.gray5
        container.layer.cornerRadius = 8

        addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        container.addSubview(titleLabel)
        container.addSubview(lineView)
        container.addSubview(calendarIcon)
        container.addSubview(dateLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        
        lineView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(20)
            make.height.equalTo(14)
            make.width.equalTo(1)
            make.centerY.equalToSuperview()
        }

        calendarIcon.snp.makeConstraints { make in
            make.leading.equalTo(lineView.snp.trailing).offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(calendarIcon.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - DatePickerSheetViewController
private final class DatePickerSheetViewController: UIViewController {
    private let onConfirm: (Date) -> Void
    private let titleText: String
    private let initialDate: Date?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 17)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.locale = Locale(identifier: "ko_KR")
        picker.backgroundColor = .systemBackground
        return picker
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        return button
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        return button
    }()

    init(title: String, initialDate: Date?, onConfirm: @escaping (Date) -> Void) {
        self.titleText = title
        self.initialDate = initialDate
        self.onConfirm = onConfirm
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if #available(iOS 13.0, *) {
            isModalInPresentation = false
        }
        view.backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        titleLabel.text = titleText
        if let initialDate = initialDate {
            datePicker.date = initialDate
        }
        setupLayout()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 15.0, *) {
            if let sheet = self.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 16
            }
        } else {
            modalPresentationStyle = .formSheet
        }
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
    }

    private func setupLayout() {
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 16

        let stack = UIStackView(arrangedSubviews: [titleLabel, datePicker, buttonStack])
        stack.axis = .vertical
        stack.spacing = 12

        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
        buttonStack.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }

    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func confirmTapped() {
        onConfirm(datePicker.date)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Helpers
extension NSRange {
    func toOptional() -> NSRange? { self.location != NSNotFound ? self : nil }
}

    
