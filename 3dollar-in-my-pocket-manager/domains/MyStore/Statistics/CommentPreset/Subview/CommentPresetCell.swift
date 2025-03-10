import UIKit

final class CommentPresetCell: BaseCollectionViewCell {
    enum Layout {
        static let iconSize = CGSize(width: 24, height: 24)
        static let maxHeight: CGFloat = 60
        
        static func calculateHeight(preset: CommentPresetResponse) -> CGFloat {
            let presetHeight = preset.body.height(font: .regular(size: 14), width: UIUtils.windowBounds.width - 76)
            if presetHeight < iconSize.height {
                return iconSize.height
            } else {
                return min(maxHeight, presetHeight)
            }
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray80
        label.font = .regular(size: 14)
        label.numberOfLines = 3
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.setImage(Assets.icMore.image, for: .normal)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private var viewModel: CommentPresetCellViewModel?
    
    override func setup() {
        super.setup()
        
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(moreButton)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(moreButton.snp.leading).offset(-12)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
    }
    
    func bind(viewModel: CommentPresetCellViewModel) {
        titleLabel.text = viewModel.output.preset.body
        
        let editAction = UIAction(
            title: Strings.CommentPresetBottomSheet.edit,
            image: Assets.icWriteLine.image.resizeImage(scaledTo: 16)
        ) { [weak self] _ in
            self?.viewModel?.input.didTapEdit.send(())
        }
        let deleteAction = UIAction(
            title: Strings.CommentPresetBottomSheet.delete,
            image: Assets.icTrash.image.resizeImage(scaledTo: 16)
        ) { [weak self] _ in
            self?.viewModel?.input.didTapDelete.send(())
        }
        moreButton.menu = UIMenu(children: [editAction, deleteAction])
        
        self.viewModel = viewModel
    }
}
