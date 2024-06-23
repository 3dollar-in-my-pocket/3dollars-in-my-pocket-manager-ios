import UIKit
import Combine
import SwiftUI

extension UploadPostViewModel {
    enum Constant {
        static let maxPhotoCount = 10
    }
    
    struct Dependency {
        let imageService: ImageServiceType
        let storePostRepository: StorePostRepository
        var userDefaults: UserDefaultsUtils
        
        init(
            imageService: ImageServiceType = ImageService(),
            storePostRepository: StorePostRepository = StorePostRepositoryImpl(),
            userDefaults: UserDefaultsUtils = UserDefaultsUtils()
        ) {
            self.imageService = imageService
            self.storePostRepository = storePostRepository
            self.userDefaults = userDefaults
        }
    }
    
    struct Config {
        let storePostApiResponse: StorePostApiResponse?
        
        init(StorePostApiResponse: StorePostApiResponse? = nil) {
            self.storePostApiResponse = StorePostApiResponse
        }
    }
    
    enum Route {
        case presentPhotoPicker(count: Int)
        case pop
    }
}


final class UploadPostViewModel {
    struct Input {
        let didTapUploadPhoto = PassthroughSubject<Void, Never>()
        let didSelectPhotos = PassthroughSubject<[UIImage], Never>()
        let didTapDeletePhoto = PassthroughSubject<Int, Never>()
        let inputContents = PassthroughSubject<String, Never>()
        let didTapUpload = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let photos: CurrentValueSubject<[ImageContent], Never>
        let message: CurrentValueSubject<String, Never>
        let isEnableSaveButton: CurrentValueSubject<Bool, Never>
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    let input = Input()
    let output: Output
    private let dependency: Dependency
    private var cancellables = Set<AnyCancellable>()
    
    init(config: Config = Config(), dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        if let post = config.storePostApiResponse {
            output = Output(
                photos: .init(post.sections.map { ImageContent(response: $0)}),
                message: .init(post.body),
                isEnableSaveButton: .init(post.body.isNotEmpty)
            )
        } else {
            output = Output(
                photos: .init([]),
                message: .init(""),
                isEnableSaveButton: .init(false)
            )
        }
        bind()
    }
    
    private func bind() {
        input.didTapUploadPhoto
            .sink { [weak self] _ in
                guard let self else { return }
                let count = Constant.maxPhotoCount - output.photos.value.count
                
                output.route.send(.presentPhotoPicker(count: count))
            }
            .store(in: &cancellables)
        
        input.didSelectPhotos
            .sink { [weak self] photos in
                guard let self else { return }
                
                let currentPhotos = output.photos.value
                let imageContents = photos.map { ImageContent(image: $0) }
                output.photos.send(currentPhotos + imageContents)
            }
            .store(in: &cancellables)
        
        input.didTapDeletePhoto
            .sink { [weak self] index in
                guard let self, output.photos.value.count - 1 >= index else { return }
                var photos = output.photos.value
                photos.remove(at: index)
                output.photos.send(photos)
            }
            .store(in: &cancellables)
        
        input.inputContents
            .sink { [weak self] message in
                self?.output.message.send(message)
                self?.output.isEnableSaveButton.send(message.isNotEmpty)
            }
            .store(in: &cancellables)
        
        input.didTapUpload
            .sink { [weak self] _ in
                self?.uploadPost()
            }
            .store(in: &cancellables)
    }
    
    private func uploadPost() {
        Task {
            let imageContents = await getImageContents()
            let body = output.message.value
            let sections = imageContents.compactMap { imageContent -> PostSectionCreateApiRequest? in
                guard let url = imageContent.url else { return nil }
                
                return PostSectionCreateApiRequest(sectionType: .image, url: url, ratio: imageContent.ratio)
            }
            let input = PostCreateApiRequest(body: body, sections: sections)
            let result = await dependency.storePostRepository.uploadPost(storeId: dependency.userDefaults.storeId, input: input)
            
            switch result {
            case .success(_):
                output.route.send(.pop)
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
    
    private func getImageContents() async -> [ImageContent] {
        var urlImageContents = output.photos.value.filter { $0.url.isNotNil }
        var uploadedImageContents = output.photos.value.filter { $0.image.isNotNil }
        let images = uploadedImageContents.compactMap { $0.image }
        
        if images.isNotEmpty {
            let result = await dependency.imageService.uploadImages(images: images, fileType: .storePostImage)
            
            switch result {
            case .success(let response):
                let uploadedImageUrls = response.map { $0.imageUrl }
                
                uploadedImageUrls.enumerated().forEach { (index, item) in
                    uploadedImageContents[index].url = item
                }
                
                return urlImageContents + uploadedImageContents
            case .failure(_):
                return urlImageContents
            }
        } else {
            return urlImageContents
        }
    }
}
