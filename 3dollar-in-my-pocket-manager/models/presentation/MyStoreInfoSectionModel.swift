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
        if menus.isEmpty {
            self.items = [.emptyMenu]
        } else if menus.count < 4 {
            let menus = menus.map { SectionItemType.menu($0) }
            
            self.items = menus
        } else {
            var sectionItemTypes = menus[..<3].map { SectionItemType.menu($0) }
            let moreItemType = SectionItemType.menuMore(Array(menus[3...]))
            
            sectionItemTypes.append(moreItemType)
            self.items = sectionItemTypes
        }
    }
    
    init(appearanceDays: [AppearanceDay]) {
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
        
        let appearanceDays = initialAppearanceDays.map { SectionItemType.appearanceDay($0) }
        
        self.items = appearanceDays
    }
}
