import Foundation

#if canImport(PromiseKit)
import PromiseKit
#elseif canImport(Combine)
import Combine
#endif

public protocol State {
    init()
}

public protocol Mutation {
    associatedtype S: State
    func mutate(_ state: S) -> S
}

#if canImport(PromiseKit)

public protocol Action {
    associatedtype S: Prestige.State
    func mutate(_ state: S) -> Promise<S>
}

public final class Store<S: Prestige.State> {
    public private(set) var state: S
    
    public init(state: S = .init()) {
        self.state = state
    }
    
    public func commit<M: Mutation>(_ mutation: M) where M.S == S {
        self.state = mutation.mutate(state)
    }
    
    public func dispatch<A: Prestige.Action>(_ action: A) -> Promise<Void> where A.S == S {
        return action.mutate(state)
        .get { self.state = $0 }
        .asVoid()
    }
}

#elseif canImport(Combine)

public protocol Action {
    associatedtype S: State
    func mutate(_ state: S) -> Future<S, Error>
}

@dynamicMemberLookup
public final class Store<S: State>: ObservableObject {
    private var subject: CurrentValueSubject<S, Error>

    public init(state: S) {
        self.subject = CurrentValueSubject(state)
    }

    public func dispatch<A: Action>(_ action: A) where A.S == S {
        action.mutate(subject.value)
        .sink(receiveCompletion: { result in
            if case let .failure(error) = result {
                self.subject.send(completion: .failure(error))
            }
        }, receiveValue: { s in
            self.subject.send(s)
        })
    }
    
    public func commit<M: Mutation>(_ mutation: M) where M.S == S {
        Just(mutation.mutate(subject.value))
        .sink(receiveCompletion: { result in
            if case let .failure(error) = result {
                self.subject.send(completion: .failure(error))
            }
        }, receiveValue: { s in
            self.subject.send(s)
        })
    }
    
    subscript<U>(dynamicMember keyPath: KeyPath<S, U>) -> U {
        subject.value[keyPath: keyPath]
    }

    public func observe<T: Equatable>(_ keyPath: KeyPath<S, T>) -> AnyPublisher<T, Error> {
        subject
        .tryMap { $0[keyPath: keyPath] }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}

#endif
