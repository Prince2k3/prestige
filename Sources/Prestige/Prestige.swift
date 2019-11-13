import Foundation

#if canImport(PromiseKit)
import PromiseKit
#endif

#if canImport(Combine)
import Combine
#endif

public protocol State {
    init()
}

public protocol Action {
    associatedtype S: Prestige.State
    func async(_ store: Store<S>) -> Promise<Void>
    
    @available(iOS 13.0, *)
    func async(_ store: Store<S>) -> Future<Void, Error>
}

@dynamicMemberLookup
open class Store<S: Prestige.State> {
    public private(set) var state: S
    
    @available(iOS 13.0, *)
    private lazy var subject: CurrentValueSubject<S, Error> = {
        return CurrentValueSubject(state)
    }()
    
    open subscript<U>(dynamicMember keyPath: KeyPath<S, U>) -> U {
        if #available(iOS 13.0, *) {
            return subject.value[keyPath: keyPath]
        } else {
            return state[keyPath: keyPath]
        }
    }
    
    public init(state: S = .init()) {
        self.state = state
    }
    
    open func commit<U>(_ keyPath: WritableKeyPath<S, U>, _ value: U) {
        if #available(iOS 13.0, *) {
            subject.value[keyPath: keyPath] = value
        } else {
            state[keyPath: keyPath] = value
        }
    }
    
    open func dispatch<A: Prestige.Action>(_ action: A) -> Promise<Void> where A.S == S {
        return action.async(self)
    }
}

@available(iOS 13.0, *)
extension Store: ObservableObject {
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
