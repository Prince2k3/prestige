import Foundation

public protocol Mutable {
    associatedtype State: DispatchState where State.Mutation == Self
}
