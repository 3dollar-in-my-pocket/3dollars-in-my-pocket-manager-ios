import Foundation

struct OperatingHours: Decodable, Hashable {
    var endTime: String
    var startTime: String
    
    init(
        endTime: String = DateUtils.toString(date: Date(), format: "HH:mm"),
        startTime: String = DateUtils.toString(date: Date(), format: "HH:mm")
    ) {
        self.endTime = endTime
        self.startTime = startTime
    }
}
