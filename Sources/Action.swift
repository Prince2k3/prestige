import Foundation

public protocol Actionable: Equatable {
    associatedtype State: DispatchState where State.Action == Self
    
    var type: String { get }
}

extension Actionable {
    private var caseName: String {
        return Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }
    
    public var type: String {
        return self.caseName.snakeCased().uppercased()
    }
    
    public var payload: Any? {
        return Mirror(reflecting: self).children.first?.value
    }
    
    public var action: PayloadRepresentation {
        return (self.type, self.payload)
    }
}
