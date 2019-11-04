import Foundation
import RxSwift

@dynamicMemberLookup
public struct EnvironmentContext<Element, Environment> {
    public let element: Element
    public let environment: Observable<Environment>
    public let appendSubscription: (Disposable) -> Void

    public init(element: Element, environment: Observable<Environment>, appendSubscription: @escaping (Disposable) -> Void) {
        self.element = element
        self.environment = environment
        self.appendSubscription = appendSubscription
    }

    public subscript<Child>(dynamicMember keyPath: KeyPath<Element, Child>) -> EnvironmentContext<Child, Environment> {
        EnvironmentContext<Child, Environment>(element: element[keyPath: keyPath], environment: environment, appendSubscription: appendSubscription)
    }
}

public extension EnvironmentContext {
    init(element: Element, environment: Observable<Environment>, disposeBag: DisposeBag) {
        self.element = element
        self.environment = environment
        self.appendSubscription = disposeBag.insert
    }

    func replacingElement<OtherElement>(_ element: OtherElement) -> EnvironmentContext<OtherElement, Environment> {
        EnvironmentContext<OtherElement, Environment>(element: element, environment: environment, appendSubscription: appendSubscription)
    }

    func map<T>(_ transform: (Element) -> T) -> EnvironmentContext<T, Environment> {
        EnvironmentContext<T, Environment>(element: transform(element), environment: environment, appendSubscription: appendSubscription)
    }

    func mapEnvironment<T>(_ transform: @escaping (Environment) -> T) -> EnvironmentContext<Element, T> {
        EnvironmentContext<Element, T>(element: element, environment: environment.map(transform), appendSubscription: appendSubscription)
    }

    func unwrapped<T>() -> EnvironmentContext<T, Environment>? where Element == Optional<T> {
        guard let element = element else { return nil }

        return EnvironmentContext<T, Environment>(element: element, environment: environment, appendSubscription: appendSubscription)
    }
}

public extension EnvironmentContext {
    func bindEnvironment<Observer: ObserverType>(to observer: Observer) where Observer.Element == Environment {
        appendSubscription(environment.bind(to: observer))
    }
}
