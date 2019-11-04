import UIKit
import RxSwift

public protocol ParametrizedCompoundStylizableElementType: class {
    associatedtype Environment
    associatedtype Argument

    typealias Context = EnvironmentContext<Self, Environment>

    func applyStylesToChildComponents(_ context: Context, arg: Argument)
}

public extension ParametrizedCompoundStylizableElementType {
    func applyStyles(for environment: Observable<Environment>, arg: Argument) -> Disposable {
        var subscriptions: [Disposable] = []
        let context = EnvironmentContext(element: self, environment: environment, appendSubscription: { subscriptions.append($0) })
        applyStylesToChildComponents(context, arg: arg)
        return Disposables.create(subscriptions)
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
