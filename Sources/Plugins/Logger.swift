import Foundation

public final class Logger: Plugin {
    public init(store: Store) {
        
    }
    
    public func subscribe(_ mutation: (type: String, payload: Any?), state: State) {
        print(mutation, state)
    }
}
