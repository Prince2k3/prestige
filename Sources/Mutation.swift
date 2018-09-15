import Foundation

public protocol Mutable: Equatable {
    associatedtype State: DispatchState where State.Mutation == Self
    
    var type: String { get }
    var payload: Any? { get }
}

extension Mutable {
    private var caseName: String {
        return Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }
    
    var type: String {
        return self.caseName.snakeCased().uppercased()
    }
    
    var payload: Any? {
        return Mirror(reflecting: self).children.first?.value
    }
    
    var mutation: (type: String, payload: Any?)? {
        return (self.type, self.payload)
    }
}
