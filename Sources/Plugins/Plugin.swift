import Foundation

public protocol Plugin {
    init(store: Store)
    func subscribe(_ mutation: Payload, state: State)
    func subscribeAction(_ action: Payload, state: State)
}

extension Plugin {
    public func subscribe(_ mutation: Payload, state: State) {
        
    }
    
    public func subscribeAction(_ action: Payload, state: State) {

    }
}
