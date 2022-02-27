import UIKit

import Base
import RxSwift
import Then
import SnapKit

extension BaseView {
    static var _disposeBag = DisposeBag()
    
    var disposeBag: DisposeBag {
        return Self._disposeBag
    }
}
