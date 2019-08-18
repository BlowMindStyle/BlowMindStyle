import UIKit
import RxSwift

public protocol ParametrizedCompoundStylizableElementType: class {
    associatedtype Environment
    associatedtype Argument

    typealias Context = EnvironmentContext<Self, Environment>

    func applyStylesToChildComponents(_ context: Context, arg: Argument) -> Disposable
}

public extension ParametrizedCompoundStylizableElementType {
    func applyStyles(for environment: Observable<Environment>, arg: Argument) -> Disposable {
        applyStylesToChildComponents(.init(element: self, environment: environment), arg: arg)
    }
}

public extension ParametrizedCompoundStylizableElementType where Self: StyleSubscriptionOwnerType {
    func applyStyles(for environment: Observable<Self.Environment>, arg: Argument) {
        setStyleSubscription(applyStyles(for: environment, arg: arg))
    }
}

public extension EnvironmentContext where Element: ParametrizedCompoundStylizableElementType, Element.Environment == Environment {
    func applyStyles(arg: Element.Argument) -> Disposable {
        element.applyStyles(for: environment, arg: arg)
    }
}
