import UIKit

struct BossStoreImage: Codable, Equatable, Hashable {
    /// ImageResponse, ImageRequest - 디코딩,인코딩용 필드
    var imageUrl: String?
    
    /// 업로드 전 로컬에서 사용하는 이미지 필드
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case imageUrl
    }
    
    init(image: UIImage? = nil, imageUrl: String? = nil) {
        self.imageUrl = imageUrl
        self.image = image
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let imageUrl {
            try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        }
    }
}

extension BossStoreImage {
    var isEmpty: Bool {
        return imageUrl.isNotNil && image.isNotNil
    }
}
