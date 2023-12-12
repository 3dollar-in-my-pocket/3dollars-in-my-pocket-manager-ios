import UIKit

extension UICollectionView {
    func register(_ types: [BaseCollectionViewCell.Type]) {
        for type in types {
            self.register(type, forCellWithReuseIdentifier: "\(type.self)")
        }
    }
    
    func dequeueReuseableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(
            withReuseIdentifier: "\(T.self)",
            for: indexPath
        ) as? T else { fatalError("정의되지 않은 UICollectionViewCell 입니다.") }
        
        return cell
    }
}
