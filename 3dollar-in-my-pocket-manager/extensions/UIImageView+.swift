import UIKit

import Kingfisher

extension UIImageView {
    func clear() {
        image = nil
        kf.cancelDownloadTask()
    }
    
    func setImage(urlString: String?) {
        if let urlString = urlString,
           let url = URL(string: urlString) {
            self.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }
    }
}
