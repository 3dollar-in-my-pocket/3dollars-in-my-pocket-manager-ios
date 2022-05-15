import Foundation

enum FeedbackType: String, Decodable {
    case bossIsKind = "BOSS_IS_KIND"
    case easyToEat = "EASY_TO_EAT"
    case foodIsDelecious = "FOOD_IS_DELECIOUS"
    case platingIsBeautiful = "PLATING_IS_BEAUTIFUL"
    case priceIsCheap = "PRICE_IS_CHEAP"
    case thereArePlacesToEatAround = "THERE_ARE_PLACES_TO_EAT_AROUND"
    
    var title: String {
        switch self {
        case .bossIsKind:
            return "🙏 사장님이 친절해요"
            
        case .easyToEat:
            return "🚀 먹기 간편해요"
            
        case .foodIsDelecious:
            return "🍕 음식이 맛있어요"
            
        case .platingIsBeautiful:
            return "🎀 플레이팅이 예뻐요"
            
        case .priceIsCheap:
            return "🌈 가격이 저렴해요"
            
        case .thereArePlacesToEatAround:
            return "🛋 주변에 먹을 곳이 있어요"
        }
    }
}
