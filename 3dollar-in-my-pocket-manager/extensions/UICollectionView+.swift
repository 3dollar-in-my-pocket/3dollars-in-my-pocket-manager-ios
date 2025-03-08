import UIKit

extension UICollectionView {
    func register(_ types: [BaseCollectionViewCell.Type]) {
        for type in types {
            self.register(type, forCellWithReuseIdentifier: "\(type.self)")
        }
    }
    
    func registerHeader(_ type: UICollectionReusableView.Type) {
        register(type, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(type.self)")
    }
    
    func registerFooter(_ type: UICollectionReusableView.Type) {
        register(type, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "\(type.self)")
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(
            withReuseIdentifier: "\(T.self)",
            for: indexPath
        ) as? T else { fatalError("정의되지 않은 UICollectionViewCell 입니다.") }
        
        return cell
    }
    
    func dequeueReusableHeader<T: UICollectionReusableView>(indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(T.self)",
            for: indexPath
        ) as? T else { fatalError("정의되지 않은 UICollectionReusableView 입니다.")}
        
        return view
    }
    
    func dequeueReusableFooter<T: UICollectionReusableView>(indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "\(T.self)",
            for: indexPath
        ) as? T else { fatalError("정의되지 않은 UICollectionReusableView 입니다.")}
        
        return view
    }
}
