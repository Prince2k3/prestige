import Foundation

public protocol Actionable {
    associatedtype State: DispatchState where State.Action == Self
}
