import Foundation
import UIKit

struct Menu: Equatable {
    /// 서버 업로드 전 단말기에서만 사용하는 이미지 필드
    var photo: UIImage?
    var imageUrl: String
    var name: String
    var price: Int
    
    var isValid: Bool {
        return (self.photo != nil || !self.imageUrl.isEmpty) && (!name.isEmpty) && (price != 0)
    }
    
    var isPlaceholder: Bool {
        return self.photo == nil && self.imageUrl == "" && self.name == "" && self.price == 0
    }
    
    init(response: BossStoreMenu) {
        self.photo = nil
        self.imageUrl = response.imageUrl ?? ""
        self.name = response.name
        self.price = response.price
    }
    
    init() {
        self.photo = nil
        self.imageUrl = ""
        self.name = ""
        self.price = 0
    }
}
