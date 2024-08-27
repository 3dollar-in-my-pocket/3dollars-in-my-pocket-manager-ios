import UIKit

extension UIImageView {
    func setImage(_ image: BossStoreImage) {
        if let imageUrl = image.imageUrl {
            setImage(urlString: imageUrl)
        } else if let image = image.image {
            self.image = image
        }
    }
}
