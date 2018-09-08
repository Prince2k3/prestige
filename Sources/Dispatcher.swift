import Foundation
@_exported import PromiseKit

public protocol Dispatchable {
    associatedtype Action: Actionable where Action.State == Self
    associatedtype Mutation: Mutable where Mutation.State == Self
    
    func dispatch(_ action: Action) -> Promise<Void>
    func commit(_ mutation: Mutation)
}

public final class Dispatcher {
    public static let shared = Dispatcher()
    
    private let cache = StateCache()
    
    private init() {
        
    }
    
    func add(_ object: Prestige.State) {
        self.cache.add(object)
    }
    
    func commit<M: Mutable>(_ mutation: M) {
        guard
            let state = self.cache.item(type: M.State.self)
            else { fatalError("State not found") }
        state.commit(mutation)
    }
    
    func dispatch<A: Actionable>(_ action: A) -> Promise<Void> {
        guard
            let state = self.cache.item(type: A.State.self)
            else { fatalError("State not found") }
        return state.dispatch(action)
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
