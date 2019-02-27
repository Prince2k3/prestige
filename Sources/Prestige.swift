import Foundation
import PromiseKit

public protocol State {
    init()
}

public protocol Action {
    associatedtype State: Prestige.State
    func mutate(_ state: State) -> Promise<State>
}

public final class Store<State: Prestige.State> {
    public private(set) var state: State
    
    public init(state: State = .init()) {
        self.state = state
    }
    
    public func dispatch<Action: Prestige.Action>(_ action: Action) -> Promise<Void> where Action.State == State {
        return action.mutate(self.state)
        .get { self.state = $0 }
        .asVoid()
    }
}