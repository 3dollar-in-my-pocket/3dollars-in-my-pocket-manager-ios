import UIKit
import Combine

extension AnyPublisher<UITapGestureRecognizer, Never> {
    func throttleClick() -> Publishers.Throttle<Self, DispatchQueue> {
        return self.throttle(for: .microseconds(500), scheduler: DispatchQueue.main, latest: false)
    }
}

extension AnyPublisher<Void, Never> {
    func throttleClick() -> Publishers.Throttle<Self, DispatchQueue> {
        return self.throttle(for: .microseconds(500), scheduler: DispatchQueue.main, latest: false)
    }
}
