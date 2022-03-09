import UIKit

import Base
import RxSwift

class BaseCollectionViewCell: Base.BaseCollectionViewCell {
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
}
