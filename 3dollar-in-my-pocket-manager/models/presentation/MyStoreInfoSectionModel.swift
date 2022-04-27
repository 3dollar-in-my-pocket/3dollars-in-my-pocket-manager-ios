import RxDataSources

struct MyStoreInfoSectionModel: Equatable {
    var items: [Item]
}

extension MyStoreInfoSectionModel: SectionModelType {
    typealias Item = SectionItemType
    
    enum SectionItemType: Equatable {
        case overview(Store)
        case introduction(String?)
        case menu(Menu)
    }
    
    init(original: MyStoreInfoSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(store: Store) {
        self.items = [.overview(store)]
    }
    
    init(introduction: String?) {
        self.items = [.introduction(introduction)]
    }
    
    init(menus: [Menu]) {
        let menus = menus.map { SectionItemType.menu($0) }
        
        self.items = menus
    }
}
