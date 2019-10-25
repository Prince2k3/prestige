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
public class Store<S: Prestige.State> {
    private(set) var state: S
    
    public subscript<U>(dynamicMember keyPath: KeyPath<S, U>) -> U {
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

public protocol Action {
    associatedtype S: State
    func async(_ store: Store<S>) -> Future<Void, Error>
}

@dynamicMemberLookup
public class Store<S: State>: ObservableObject {
    private var subject: CurrentValueSubject<S, Error>

    public subscript<U>(dynamicMember keyPath: KeyPath<S, U>) -> U {
        subject.value[keyPath: keyPath]
    }
    
    public init(state: S) {
        self.subject = CurrentValueSubject(state)
    }
    
    open func commit<U>(_ keyPath: WritableKeyPath<S, U>, _ value: U) {
        subject.value[keyPath: keyPath] = value
    }

    open func dispatch<A: Prestige.Action>(_ action: A) where A.S == S {
        action.async(self)
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
