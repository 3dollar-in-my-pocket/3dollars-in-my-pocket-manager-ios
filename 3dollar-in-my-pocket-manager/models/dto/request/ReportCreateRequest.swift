import Foundation

struct ReportCreateRequest: Encodable {
    let reason: String = "REVIEW_ETC"
    let reasonDetail: String
}
