import UIKit

import Kingfisher

extension UIImageView {
    func clear() {
        image = nil
        kf.cancelDownloadTask()
    }
}
