import Foundation

public protocol Plugin {
    init(store: Store)
    func subscribe(_ mutation: (type: String, payload: Any?))
    func subscribeAction(_ action: (type: String, payload: Any?))
}

extension Plugin {
    public func subscribe(_ mutation: (type: String, payload: Any?)) {
        
    }
    
    public func subscribeAction(_ action: (type: String, payload: Any?)) {

    }
}
