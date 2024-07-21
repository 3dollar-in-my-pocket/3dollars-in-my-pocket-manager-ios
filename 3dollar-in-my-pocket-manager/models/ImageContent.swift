import UIKit

struct ImageContent: Identifiable {
    let id = ObjectIdentifier(Self.self)
    
    var image: UIImage?
    var url: String?
    let ratio: Double
    
    init(image: UIImage) {
        self.image = image
        self.url = nil
        self.ratio = image.size.width / image.size.height
    }
    
    init(response: PostSectionApiResponse) {
        self.image = nil
        self.url = response.url
        self.ratio = response.ratio
    }
}
