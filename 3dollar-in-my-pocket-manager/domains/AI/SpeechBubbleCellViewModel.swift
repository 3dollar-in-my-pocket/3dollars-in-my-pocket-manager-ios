extension SpeechBubbleCellViewModel {
    struct Output {
        let text: String
        let boldText: String?
    }
    
    struct Config {
        let text: String
        let boldText: String?
    }
}

final class SpeechBubbleCellViewModel: BaseViewModel, Identifiable {
    let output: Output
    lazy var id = ObjectIdentifier(self)
    
    init(config: Config) {
        self.output = Output(text: config.text, boldText: config.boldText)
        super.init()
    }
}

extension SpeechBubbleCellViewModel: Hashable {
    static func == (lhs: SpeechBubbleCellViewModel, rhs: SpeechBubbleCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
