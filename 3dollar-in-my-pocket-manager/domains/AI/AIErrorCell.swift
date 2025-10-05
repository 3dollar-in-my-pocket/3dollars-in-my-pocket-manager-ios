import UIKit
import CombineCocoa

final class AIErrorCell: BaseCollectionViewCell {
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .medium(size: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let retryButtton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .bold(size: 16)
        button.setTitle("다시 시도", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = .green
        return button
    }()
    
    override func setup() {
        super.setup()
        
        contentView.addSubViews([
            errorLabel,
            retryButtton
        ])
        
        
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        errorLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().offset(24)
        }
        
        retryButtton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(errorLabel.snp.bottom).offset(12)
            $0.bottom.equalToSuperview().offset(-12)
            $0.height.equalTo(48)
        }
    }
    
    func bind(viewModel: AIErrorCellViewModel) {
        bindError(viewModel.output.error)
        
        retryButtton.tapPublisher
            .throttleClick()
            .mapVoid
            .subscribe(viewModel.input.didTapRetry)
            .store(in: &cancellables)
    }
    
    private func bindError(_ error: Error) {
        if let apiError = error as? ApiError,
           case .errorContainer(let apiErrorContainer) = apiError,
           let message = apiErrorContainer.message {
            errorLabel.text = message
        } else if let localizedError = error as? LocalizedError,
                  let description = localizedError.errorDescription {
            errorLabel.text = description
        } else {
            errorLabel.text = error.localizedDescription
        }
    }
}
