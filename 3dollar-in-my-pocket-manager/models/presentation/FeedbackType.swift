import Foundation

enum FeedbackType: String, Decodable {
    case bossIsKind = "BOSS_IS_KIND"
    case easyToEat = "EASY_TO_EAT"
    case foodIsDelecious = "FOOD_IS_DELICIOUS"
    case platingIsBeautiful = "PLATING_IS_BEAUTIFUL"
    case priceIsCheap = "PRICE_IS_CHEAP"
    case thereArePlacesToEatAround = "THERE_ARE_PLACES_TO_EAT_AROUND"
    
    var title: String {
        switch self {
        case .bossIsKind:
            return "statistics_boss_is_kind".localized
            
        case .easyToEat:
            return "statistics_easy_to_eat".localized
            
        case .foodIsDelecious:
            return "statistics_food_is_delecious".localized
            
        case .platingIsBeautiful:
            return "statistics_plating_is_beautiful".localized
            
        case .priceIsCheap:
            return "statistics_price_is_cheap".localized
            
        case .thereArePlacesToEatAround:
            return "statistics_there_are_places_to_eat_around".localized
        }
    }
}
