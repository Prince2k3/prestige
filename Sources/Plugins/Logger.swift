import Foundation

public final class Logger: Plugin {
    public init(store: Store) {
        
    }
    
    public func subscribe(_ mutation: Payload, state: State) {
        print(mutation)
        print(state)
    }
}
