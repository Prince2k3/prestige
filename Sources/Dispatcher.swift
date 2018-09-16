import Foundation
@_exported import PromiseKit

public typealias Payload = (type: String, payload: Any?)

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
    var mutations: [Payload] = []
    var actions: [Payload] = []
    private init() {}
    
    func add(_ object: Prestige.State) {
        self.cache.add(object)
    }
    
    func commit<M: Mutable>(_ mutation: M) {
        guard
            let state = self.cache.item(type: M.State.self)
            else { fatalError("State not found") }
        self.mutations.append(mutation.mutation)
        state.commit(mutation)
        self.plugins.forEach {
            $0.subscribe(mutation.mutation, state: state)
        }
    }
    
    func dispatch<A: Actionable>(_ action: A) -> Promise<Void> {
        guard
            let state = self.cache.item(type: A.State.self)
            else { fatalError("State not found") }
        self.actions.append(action.action)
        return state.dispatch(action)
        .get {
            self.plugins.forEach {
                $0.subscribeAction(action.action, state: state)
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
