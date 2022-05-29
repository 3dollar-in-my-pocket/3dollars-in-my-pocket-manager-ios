import ReactorKit
import UIKit

final class EditMenuReactor {
    enum Action {
        case addPhoto(index: Int, photo: UIImage)
        case inputMenuName(index: Int, name: String)
        case inputMenuPrice(index: Int, price: String)
        case tapDeleteMenuButton(index: Int)
        case tapAddMenuButton
        case tapSaveButton
    }
    
    enum Mutation {
        case setPhoto(index: Int, photo: UIImage)
    }
    
    struct State {
        var store: Store
        var isAddMenuButtonHidden: Bool
        var isEnableSaveButton: Bool
    }
}
