import Foundation

public protocol State {}

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



fileprivate extension String {
    func lowercasingFirstLetter() -> String {
        return prefix(1).lowercased() + dropFirst()
    }
}

public typealias DispatchState = Prestige.State & Prestige.Dispatchable
