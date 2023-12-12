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
        case menuMore([Menu])
        case emptyMenu
        case appearanceDay(AppearanceDay)
        case account(AccountInfo?)
    }
    
    static func overview(_ store: Store) -> MyStoreInfoSectionModel {
        return .init(items: [.overview(store)])
    }
    
    static func introduction(_ introduction: String?) -> MyStoreInfoSectionModel {
        return .init(items: [.introduction(introduction)])
    }
    
    static func account(_ accountInfo: AccountInfo?) -> MyStoreInfoSectionModel {
        return .init(items: [.account(accountInfo)])
    }
    
    static func menus(_ menus: [Menu]) -> MyStoreInfoSectionModel {
        if menus.isEmpty {
            return .init(items: [.emptyMenu])
        } else if menus.count < 4 {
            let menus = menus.map { SectionItemType.menu($0) }
            
            return .init(items: menus)
        } else {
            var sectionItemTypes = menus[..<3].map { SectionItemType.menu($0) }
            let moreItemType = SectionItemType.menuMore(Array(menus[3...]))
            
            sectionItemTypes.append(moreItemType)
            
            return .init(items: sectionItemTypes)
        }
    }
    
    static func appearanceDays(_ appearanceDays: [AppearanceDay]) -> MyStoreInfoSectionModel {
        var initialAppearanceDays = [
            AppearanceDay(dayOfTheWeek: .monday, isClosed: true),
            AppearanceDay(dayOfTheWeek: .tuesday, isClosed: true),
            AppearanceDay(dayOfTheWeek: .wednesday, isClosed: true),
            AppearanceDay(dayOfTheWeek: .thursday, isClosed: true),
            AppearanceDay(dayOfTheWeek: .friday, isClosed: true),
            AppearanceDay(dayOfTheWeek: .saturday, isClosed: true),
            AppearanceDay(dayOfTheWeek: .sunday, isClosed: true)
        ]
        
        for appearanceDay in appearanceDays {
            initialAppearanceDays[appearanceDay.index] = appearanceDay
        }
        
        let items = initialAppearanceDays.map { SectionItemType.appearanceDay($0) }
        
        return .init(items: items)
    }
    
    init(original: MyStoreInfoSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}
