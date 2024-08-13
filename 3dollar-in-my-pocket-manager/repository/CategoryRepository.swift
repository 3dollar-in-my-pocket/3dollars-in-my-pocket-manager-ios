protocol CategoryRepository {
    func fetchCategories() async -> ApiResult<[StoreFoodCategoryResponse]>
}


final class CategoryRepositoryImpl: CategoryRepository {
    func fetchCategories() async -> ApiResult<[StoreFoodCategoryResponse]> {
        return await CategoryApi.fetchCategories.asyncRequest()
    }
}
