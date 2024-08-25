struct StoreCategory: Equatable {
    let categoryId: String
    let name: String
    
    init(response: StoreCategoryResponse) {
        self.categoryId = response.categoryId
        self.name = response.name
    }
    
    init(response: StoreFoodCategoryResponse) {
        self.categoryId = response.categoryId
        self.name = response.name
    }
}
