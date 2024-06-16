import Foundation

struct StoreApiResponse: Decodable {
    let storeType: StoreType
    let storeId: String
    let isOwner: Bool
    let account: AccountResponse?
    let storeName: String
    let address: AddressResponse?
    let location: LocationResponse?
    let categories: [StoreFoodCategoryResponse]
    let isDeleted: Bool
    let activitiesStatus: ActivitiesStatus
    let createdAt: String
    let updatedAt: String
}
