import Foundation
import Combine

extension AIViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let afterDefaultMessage = PassthroughSubject<Void, Never>()
        let didReceivedResponse = PassthroughSubject<String, Never>()
    }
    
    struct Output {
        let datasource = CurrentValueSubject<[AISection], Never>([])
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let aiRepository: AIRepository
        let preference: Preference
        
        init(
            aiRepository: AIRepository = AIRepositoryImpl(),
            preference: Preference = .shared
        ) {
            self.aiRepository = aiRepository
            self.preference = preference
        }
    }
}

final class AIViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private let dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.load
            .sink { [weak self] in
                self?.output.datasource.send([])
                self?.getAIRecommendation()
                self?.addDefaultSpeechBubble()
            }
            .store(in: &cancellables)
        
        Publishers.Zip(input.afterDefaultMessage, input.didReceivedResponse)
            .sink { [weak self] (_, markdown: String) in
                self?.addRecommendation(markdown: markdown)
            }
            .store(in: &cancellables)
    }
    
    private func getAIRecommendation() {
        Task {
            do {
                let storeId = Int(dependency.preference.storeId) ?? 0
                let response = try await dependency.aiRepository.getRecommendation(
                    storeId: storeId,
                    date: Date().toString(format: "yyyy-MM-dd")
                ).get()
                
                input.didReceivedResponse.send(response.text)
            } catch {
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func addDefaultSpeechBubble() {
        let storeName = dependency.preference.storeName
        let cellViewModel = SpeechBubbleCellViewModel(config: .init(
            text: Strings.Ai.firstSpeechBubble(storeName),
            boldText: nil
        ))
        var section = AISection(items: [.speechBubble(cellViewModel)])
        
        output.datasource.send([section])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            
            let dateString = Date().toString(format: Strings.Ai.dateFormat)
            
            let cellViewModel = SpeechBubbleCellViewModel(config: .init(
                text: Strings.Ai.secondSpeechBubble(dateString),
                boldText: dateString
            ))
            section.items.append(.speechBubble(cellViewModel))
            section.items.append(.loading)
            output.datasource.send([section])
            input.afterDefaultMessage.send(())
        }
    }
    
    private func addRecommendation(markdown: String) {
        var sections = output.datasource.value
        
        guard var items = sections.first?.items else { return }
        if let loadingIndex = items.firstIndex(of: .loading) {
            items.remove(at: loadingIndex)
        }
        let cellViewModel = AIResponseCellViewModel(config: .init(markdown: markdown))
        bindAIResponseCellViewModel(cellViewModel)
        items.append(.recommendation(cellViewModel))
        sections = [.init(items: items)]
        
        output.datasource.send(sections)
    }
    
    private func bindAIResponseCellViewModel(_ viewModel: AIResponseCellViewModel) {
        viewModel.output.onError
            .sink { [weak self] error in
                self?.output.route.send(.showErrorAlert(error))
            }
            .store(in: &viewModel.cancellables)
    }
}
