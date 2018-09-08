import Foundation
@_exported import PromiseKit

open class Store {
    private let dispatcher: Dispatcher = .shared
    
    private var states: [State] {
        let mirror = Mirror(reflecting: self)
        let states = mirror.children.compactMap { $0.value as? State }
        return states
    }
    
    public init() {
        self.states.forEach { Dispatcher.shared.add($0) }
    }

    public func dispatch<A: Actionable>(_ action: A) -> Promise<Void> {
        return self.dispatcher.dispatch(action)
    }

    public func commit<M: Mutable>(_ mutation: M) {
        self.dispatcher.commit(mutation)
    }
}
