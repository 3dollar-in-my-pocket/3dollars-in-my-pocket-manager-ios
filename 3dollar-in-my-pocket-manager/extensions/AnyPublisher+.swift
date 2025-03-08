import UIKit
import Combine

extension AnyPublisher<UITapGestureRecognizer, Never> {
    func throttleClick() -> Publishers.Throttle<Self, DispatchQueue> {
        return self.throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: false)
    }
}

extension AnyPublisher<Void, Never> {
    func throttleClick() -> Publishers.Throttle<Self, DispatchQueue> {
        return self.throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: false)
    }
}
