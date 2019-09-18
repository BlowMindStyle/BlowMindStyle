import Foundation
import RxSwift

@dynamicMemberLookup
public struct EnvironmentContext<Element, Environment> {
    public let element: Element
    public let environment: Observable<Environment>

    public init(element: Element, environment: Observable<Environment>) {
        self.element = element
        self.environment = environment
    }

    public subscript<Child>(dynamicMember keyPath: KeyPath<Element, Child>) -> EnvironmentContext<Child, Environment> {
        EnvironmentContext<Child, Environment>(element: element[keyPath: keyPath], environment: environment)
    }
}

public extension EnvironmentContext {
    func replacingElement<OtherElement>(_ element: OtherElement) -> EnvironmentContext<OtherElement, Environment> {
        EnvironmentContext<OtherElement, Environment>(element: element, environment: environment)
    }

    func map<T>(_ transform: (Element) -> T) -> EnvironmentContext<T, Environment> {
        EnvironmentContext<T, Environment>(element: transform(element), environment: environment)
    }

    func mapEnvironment<T>(_ transform: @escaping (Environment) -> T) -> EnvironmentContext<Element, T> {
        EnvironmentContext<Element, T>(element: element, environment: environment.map(transform))
    }

    func unwrapped<T>() -> EnvironmentContext<T, Environment>? where Element == Optional<T> {
        guard let element = element else { return nil }

        return EnvironmentContext<T, Environment>(element: element, environment: environment)
    }
}
