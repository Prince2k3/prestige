import Foundation
@_exported import PromiseKit

public protocol Dispatchable {
    associatedtype Action: Actionable
    associatedtype Mutation: Mutable
    
    func dispatch(_ action: Action) -> Promise<Void>
    func commit(_ mutation: Mutation)
}

public final class Dispatcher {
    public static let shared = Dispatcher()
    
    private let cache = StateCache()
    
    var plugins: [Plugin] = []
    
    private init() {}
    
    func add(_ object: Prestige.State) {
        self.cache.add(object)
    }
    
    func commit<M: Mutable>(_ mutation: M) {
        guard
            let state = self.cache.item(type: M.State.self)
            else { fatalError("State not found") }
        state.commit(mutation)
        self.plugins.forEach {
            if let mutation = mutation.mutation {
                $0.subscribe(mutation, state: state)
            }
        }
    }
    
    func dispatch<A: Actionable>(_ action: A) -> Promise<Void> {
        guard
            let state = self.cache.item(type: A.State.self)
            else { fatalError("State not found") }
        return state.dispatch(action)
        .get {
            self.plugins.forEach {
                if let action = action.action {
                    $0.subscribeAction(action, state: state)
                }
            }
        }
    }
}

/// ---

fileprivate final class StateCache {
    private var items: [String: Any] = [:]
    
    func item<T: Prestige.State>(type: T.Type) -> T? {
        return self.items[T.identifier] as? T
    }
    
    func add(_ object: Prestige.State) {
        let identifier = type(of: object).identifier
        guard
            self.items[identifier] == nil
            else { return }
        self.items[identifier] = object
    }
}
