import UIKit

struct BossStoreImage: Codable, Equatable, Hashable {
    /// ImageResponse - 디코딩용 필드
    var imageUrl: String? // 디코딩용
    
    /// 업로드 전 로컬에서 사용하는 이미지 필드
    var image: UIImage?
    
    /// ImageRequest - 인코딩용 필드
    var url: String?
    
    enum CodingKeys: String, CodingKey {
        case imageUrl
        case url
    }
    
    init(image: UIImage) {
        self.image = image
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let url {
            try container.encodeIfPresent(url, forKey: .url)
        } else if let imageUrl {
            try container.encodeIfPresent(imageUrl, forKey: .url)
        }
    }
}
