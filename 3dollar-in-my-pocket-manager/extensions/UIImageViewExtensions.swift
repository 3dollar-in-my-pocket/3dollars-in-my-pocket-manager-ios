import UIKit

import Kingfisher

extension UIImageView {
    func setImage(urlString: String?) {
        if let urlString = urlString,
           let url = URL(string: urlString) {
            self.kf.setImage(with: url)
        }
    }
}
