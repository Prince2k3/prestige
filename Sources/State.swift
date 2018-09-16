import Foundation

public protocol State: CustomStringConvertible {}

extension State {
    public static var identifier: String {
        let suffix = "State"
        let string = String(describing: self)
        if string.hasSuffix(suffix) {
            return String(string.dropLast(suffix.count)).lowercasingFirstLetter()
        }
        return string.lowercasingFirstLetter()
    }
}

extension State {
    var description : String {
        var description = "***** \(type(of: self)) *****\n"
        
        let this = Mirror(reflecting: self)
        for child in this.children {
            guard let propertyName = child.label else { continue }
            description += "\(propertyName): \(child.value)\n"
        }
        
        return description
    }
}

public typealias DispatchState = Prestige.State & Prestige.Dispatchable
