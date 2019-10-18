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
    func mutate(_ state: S) -> Promise<S>
}

public final class Store<S: Prestige.State> {
    public private(set) var state: S
    
    public init(state: S = .init()) {
        self.state = state
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
    func mutate(_ state: S) -> AnyPublisher<S, Error>
}

public final class Store<S: State>: ObservableObject {
    private var subject: CurrentValueSubject<S, Error>
    private var cancellable: Cancellable?
    
    @Published public var state: S
    
    deinit {
        cancellable?.cancel()
        cancellable = nil
    }
    
    public init(state: S) {
        self.state = state
        self.subject = CurrentValueSubject(state)
    }
    
    public func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }

    public func dispatch<A: Prestige.Action>(_ action: A) where A.S == S {
        cancellable = action.mutate(state)
        .sink(receiveCompletion: { result in
            if case let .failure(error) = result {
                self.subject.send(completion: .failure(error))
            }
        }, receiveValue: { s in
            DispatchQueue.main.async {
                self.state = s
            }
            
            self.subject.send(s)
        })
    }

    public func observe<T: Equatable>(_ keyPath: KeyPath<S, T>) -> AnyPublisher<T, Error> {
        subject
        .tryMap { $0[keyPath: keyPath] }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}

#endif
