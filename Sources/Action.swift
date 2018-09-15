import Foundation

public protocol Actionable: Equatable {
    associatedtype State: DispatchState where State.Action == Self
    
    var type: String { get }
}

extension Actionable {
    private var caseName: String {
        return Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }
    
    var type: String {
        return self.caseName.snakeCased().uppercased()
    }
    
    var payload: Any? {
        return Mirror(reflecting: self).children.first?.value
    }
    
    var action: (type: String, payload: Any?)? {
        return (self.type, self.payload)
    }
}
