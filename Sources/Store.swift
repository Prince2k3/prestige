import Foundation
import PromiseKit

public protocol State {
    init()
}

public protocol Action {
    associatedtype State: Prestige.State
    func mutate(_ state: State, completion: @escaping (Result<State>) -> Void)
}

public final class Store<State: Prestige.State> {
    public private(set) var state: State
    
    public init(state: State = .init()) {
        self.state = state
    }
    
    public func dispatch<Action: Prestige.Action>(_ action: Action) -> Promise<Void> where Action.State == State {
        return Promise { seal in
            action.mutate(self.state) { result in
                switch result {
                case .fulfilled:
                    seal.fulfill(())
                case let .rejected(error):
                    seal.reject(error)
                }
            }
        }
    }
}
