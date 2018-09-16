import Foundation
@_exported import PromiseKit

open class Store  {
    private let dispatcher: Dispatcher = .shared
    private var plugins: [Plugin] = []
    
    private var states: [State] {
        return collectStates(Mirror(reflecting: self))
    }
    
    public init(plugins: [Plugin.Type] = [], debug: Bool = false) {
        self.states.forEach { Dispatcher.shared.add($0) }
        self.plugins = (plugins + (debug ? [Logger.self] : [])).map { $0.init(store: self) }
    }

    public func dispatch<A: Actionable>(_ action: A) -> Promise<Void> {
        return self.dispatcher.dispatch(action)
        .get {
            self.plugins.forEach {
                if let action = action.action {
                    $0.subscribeAction(action)
                }
            }
        }
    }

    public func commit<M: Mutable>(_ mutation: M) {
        self.dispatcher.commit(mutation)
        self.plugins.forEach {
            if let mutation = mutation.mutation {
                $0.subscribe(mutation)
            }
        }
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
