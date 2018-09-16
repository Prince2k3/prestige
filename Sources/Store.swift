import Foundation
@_exported import PromiseKit

open class Store  {
    private let dispatcher: Dispatcher = .shared
    
    private var states: [State] {
        return collectStates(Mirror(reflecting: self))
    }
    
    public init(plugins: [Plugin.Type] = [], debug: Bool = false) {
        self.states.forEach { Dispatcher.shared.add($0) }
        Dispatcher.shared.plugins = (plugins + (debug ? [Logger.self] : [])).map { $0.init(store: self) }
    }

    public func dispatch<A: Actionable>(_ action: A) -> Promise<Void> {
        return self.dispatcher.dispatch(action)
    }

    public func commit<M: Mutable>(_ mutation: M) {
        self.dispatcher.commit(mutation)
    }
}

extension Store {
    private func collectStates(_ mirror: Mirror) -> [State] {
        var states = [State]()
        for (_, value) in mirror.children {
            guard let value = value as? State else { continue }
            states.append(value)
            states.append(contentsOf: collectStates(Mirror(reflecting: value)))
        }
        return states
    }
}
