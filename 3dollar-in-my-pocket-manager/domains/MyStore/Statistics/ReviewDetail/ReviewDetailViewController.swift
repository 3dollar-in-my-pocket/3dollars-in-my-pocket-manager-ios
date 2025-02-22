import UIKit

final class ReviewDetailViewController: BaseViewController {
    private let scrollView = UIScrollView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let reviewItemView = ReviewItemView()
    
    private let commentInputView = ReviewDetailCommentInputView()
    
    private let commentView = ReviewDetailCommentView()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.ReviewDetail.comment, for: .normal)
        button.setTitleColor(.gray0, for: .normal)
        button.titleLabel?.font = .medium(size: 16)
        return button
    }()
    
    private let bottomButtonBackground = UIView()
    
    
    private let viewModel: ReviewDetailViewModel
    private var originalBottomInset: CGFloat = 0
    private let tapGesture = UITapGestureRecognizer()
    
    init(viewModel: ReviewDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
        bind()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupKeyboardEvent()
        viewModel.input.firstLoad.send(())
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        addNavigationBar()
        setupNavigationBar()
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(didTapScrollView))
        tapGesture.cancelsTouchesInView = false
        
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
            make.height.equalTo(UIUtils.windowBounds.width)
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.width.equalTo(UIUtils.windowBounds.width)
            make.bottom.equalToSuperview()
        }
        
        stackView.addArrangedSubview(reviewItemView)
    }
    
    private func bind() {
        // Input
        commentButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapComment)
            .store(in: &cancellables)
        
        commentView.deleteCommentButton.tapPublisher
            .main
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewController, _) in
                owner.presentDeleteAlert()
            }
            .store(in: &cancellables)
        
        // Output
        viewModel.output.review
            .main
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewController, reviewItemViewModel: ReviewItemViewModel) in
                owner.reviewItemView.bind(viewModel: reviewItemViewModel)
            }
            .store(in: &cancellables)
        
        viewModel.output.comment
            .main
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewController, data) in
                let (comment, name) = data
                owner.clearCommentView()
                if let comment {
                    owner.setupComment(comment, name: name)
                } else {
                    owner.setupCommentInput()
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.enableComment
            .main
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewController, isEnable: Bool) in
                owner.setEnableReplayButton(isEnable)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: ReviewDetailViewController, route: ReviewDetailViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func setupNavigationBar() {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.attributedTitle = AttributedString(
            Strings.ReviewDetail.report,
            attributes: AttributeContainer([
                .foregroundColor: UIColor.red,
                .font: UIFont.semiBold(size: 14) as Any
            ])
        )
        
        let backButton = UIButton(configuration: buttonConfig)
        backButton.addTarget(self, action: #selector(didTapReport), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func setEnableReplayButton(_ isEnable: Bool) {
        let backgroundColor: UIColor = isEnable ? .green : .gray30
        bottomButtonBackground.backgroundColor = backgroundColor
        commentButton.backgroundColor = backgroundColor
        commentButton.isEnabled = isEnable
    }
    
    private func setupCommentInput() {
        setEnableReplayButton(false)
        view.addSubview(commentButton)
        view.addSubview(bottomButtonBackground)
        stackView.addArrangedSubview(commentInputView)
        commentInputView.snp.makeConstraints { make in
            make.height.equalTo(ReviewDetailCommentInputView.Layout.height)
        }
        
        bottomButtonBackground.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        commentButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(bottomButtonBackground.snp.top)
            make.height.equalTo(64)
        }
        
        scrollView.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(commentButton.snp.top)
            make.height.equalTo(UIUtils.windowBounds.width)
        }
        
        commentInputView.textPublisher
            .subscribe(viewModel.input.inputReply)
            .store(in: &commentInputView.cancellables)
    }
    
    private func clearCommentView() {
        commentButton.removeFromSuperview()
        commentButton.snp.removeConstraints()
        bottomButtonBackground.removeFromSuperview()
        bottomButtonBackground.snp.removeConstraints()
        commentInputView.removeFromSuperview()
        commentView.removeFromSuperview()
    }
    
    private func setupComment(_ comment: CommentResponse, name: String) {
        stackView.addArrangedSubview(commentView)
        commentView.bind(comment: comment, name: name)
    }
    
    @objc private func didTapReport() {
        viewModel.input.didTapReport.send(())
    }
    
    @objc private func didTapScrollView() {
        view.endEditing(true)
    }
    
    private func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onShowKeyboard(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onHideKeyboard(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func onShowKeyboard(notification: Notification) {
        let keyboardHeight = mapNotificationToKeyboardHeight(notification: notification)
        let inset = keyboardHeight > 0 ? (keyboardHeight - view.safeAreaInsets.bottom) : 0
        originalBottomInset = scrollView.contentInset.bottom
        scrollView.contentInset.bottom += inset
        scrollView.contentOffset.y += inset
        
    }
    
    @objc func onHideKeyboard(notification: Notification) {
        scrollView.contentInset.bottom = originalBottomInset
        scrollView.contentOffset.y -= originalBottomInset
    }
    
    private func mapNotificationToKeyboardHeight(notification: Notification) -> CGFloat {
        if notification.name == UIResponder.keyboardDidShowNotification ||
            notification.name == UIResponder.keyboardWillShowNotification {
            let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            return rect.height
        } else {
            return 0
        }
    }
    
    private func presentDeleteAlert() {
        AlertUtils.showWithCancel(
            viewController: self,
            message: Strings.ReviewDetail.Alert.delete,
            onTapOk: { [weak self] in
                self?.viewModel.input.didTapDeleteComment.send(())
            }
        )
    }
}


// MARK: Route
extension ReviewDetailViewController {
    private func handleRoute(_ route: ReviewDetailViewModel.Route) {
        switch route {
        case .back:
            navigationController?.popViewController(animated: true)
        case .presentPhotoDetail(let viewModel):
            presentPhotoDetail(viewModel: viewModel)
        case .presentReportBottomSheet(let viewModel):
            presentReportBottomSheet(viewModel: viewModel)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
    
    private func presentPhotoDetail(viewModel: PhotoDetailViewModel) {
        let viewController = PhotoDetailViewController(viewModel: viewModel)
        present(viewController, animated: true)
    }
    
    private func presentReportBottomSheet(viewModel: ReviewReportBottomSheetViewModel) {
        let viewController = ReviewReportBottomSheet(viewModel: viewModel)
        presentPanModal(viewController)
    }
}
