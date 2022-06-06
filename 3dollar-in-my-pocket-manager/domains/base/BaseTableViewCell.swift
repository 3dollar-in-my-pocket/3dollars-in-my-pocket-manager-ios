import UIKit

import Base
import RxSwift

class BaseTableViewCell: Base.BaseTableViewCell {
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
}
