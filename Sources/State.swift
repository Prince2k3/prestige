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

public typealias DispatchState = Prestige.State & Prestige.Dispatchable


//store.dispatch(.increment(1))
//
//// vs
//
//store.counter.dispatch(.increment(1)) // works
