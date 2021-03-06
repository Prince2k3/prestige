import Foundation

#if canImport(PromiseKit)
import PromiseKit
#elseif canImport(Combine)
import Combine
#endif

public protocol State {
    init()
}

#if canImport(PromiseKit)

public protocol Action {
    associatedtype S: Prestige.State
    func async(_ store: Store<S>) -> Promise<Void>
}

@dynamicMemberLookup
open class Store<S: Prestige.State> {
    public private(set) var state: S
    
    open subscript<U>(dynamicMember keyPath: KeyPath<S, U>) -> U {
        state[keyPath: keyPath]
    }
    
    public init(state: S = .init()) {
        self.state = state
    }
    
    open func commit<U>(_ keyPath: WritableKeyPath<S, U>, _ value: U) {
        state[keyPath: keyPath] = value
    }
    
    open func dispatch<A: Prestige.Action>(_ action: A) -> Promise<Void> where A.S == S {
        return action.async(self)
    }
}

#elseif canImport(Combine)

@available(iOS 13.0, macOS 10.15, *)
public protocol Action {
    associatedtype S: Prestige.State
    func async(_ store: Store<S>) -> Future<Void, Error>
}

@available(iOS 13.0, macOS 10.15, *)
@dynamicMemberLookup
open class Store<S: Prestige.State>: ObservableObject {
    private var subject: CurrentValueSubject<S, Error>

    open subscript<U>(dynamicMember keyPath: KeyPath<S, U>) -> U {
        subject.value[keyPath: keyPath]
    }
    
    public init(state: S = .init()) {
        self.subject = CurrentValueSubject(state)
    }
    
    open func commit<U>(_ keyPath: WritableKeyPath<S, U>, _ value: U) {
        subject.value[keyPath: keyPath] = value
    }

    open func dispatch<A: Prestige.Action>(_ action: A) where A.S == S {
        _ = action.async(self)
        .sink(receiveCompletion: { result in
            if case let .failure(error) = result {
                self.subject.send(completion: .failure(error))
            }
        }, receiveValue: { _ in
            self.subject.send(self.subject.value)
        })
    }

    open func observe<T: Equatable>(_ keyPath: KeyPath<S, T>) -> AnyPublisher<T, Error> {
        subject
        .tryMap { $0[keyPath: keyPath] }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}

#endif
