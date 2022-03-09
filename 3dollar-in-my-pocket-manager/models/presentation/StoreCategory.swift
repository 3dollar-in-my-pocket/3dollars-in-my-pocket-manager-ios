struct StoreCategory {
    let categoryId: String
    let name: String
    
    init(response: StoreCategoryResponse) {
        self.categoryId = response.categoryId
        self.name = response.name
    }
}
