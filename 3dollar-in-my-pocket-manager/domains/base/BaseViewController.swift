import UIKit

import Base
import RxSwift

class BaseViewController: Base.BaseViewController {
    var disposeBag = DisposeBag()
    var eventDisposeBag = DisposeBag()
}
