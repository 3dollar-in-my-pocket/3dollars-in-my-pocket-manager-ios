import Foundation

import Combine

public final class AnyCancelTaskBag {
    private var tasks: [any AnyCancellableTask] = []
    
    init() {}

    func add(task: any AnyCancellableTask) {
        tasks.append(task)
    }

    func cancel() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    deinit {
        cancel()
    }
}


extension Task {
    func store(in bag: AnyCancelTaskBag) {
        bag.add(task: self)
    }
}

protocol AnyCancellableTask {
    func cancel()
}

extension Task: AnyCancellableTask {}
