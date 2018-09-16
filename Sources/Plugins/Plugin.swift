import Foundation

public protocol Plugin {
    init(store: Store)
    func subscribe(_ mutation: (type: String, payload: Any?), state: State)
    func subscribeAction(_ action: (type: String, payload: Any?), state: State)
}

extension Plugin {
    public func subscribe(_ mutation: (type: String, payload: Any?), state: State) {
        
    }
    
    public func subscribeAction(_ action: (type: String, payload: Any?), state: State) {

    }
}
