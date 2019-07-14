import UIKit
import RxSwift

public protocol CompoundStylizableElementType: class {
    associatedtype Environment

    typealias StyleContext = EnvironmentContext<Self, Environment>

    func applyStylesToChildComponents(_ context: StyleContext) -> Disposable
}

public extension CompoundStylizableElementType {
    func applyStyles(for environment: Observable<Environment>) -> Disposable {
        applyStylesToChildComponents(.init(element: self, environment: environment))
    }
}

public extension CompoundStylizableElementType where Self: StyleSubscriptionOwnerType {
    func applyStyles(for environment: Observable<Self.Environment>) {
        setStyleSubscription(applyStyles(for: environment))
    }
}

public extension EnvironmentContext where Element: CompoundStylizableElementType, Element.Environment == Environment {
    func applyStyles() -> Disposable {
        element.applyStyles(for: environment)
    }
}

public extension CompoundStylizableElementType where Self: UIViewController, Self: StyleSubscriptionOwnerType {
    func applyStylesOnLoad(for environment: Observable<Self.Environment>) {
        if viewIfLoaded != nil {
            applyStyles(for: environment)
        } else {
            let loaded = rx.methodInvoked(#selector(UIViewController.viewDidLoad)).take(1)

            let subscription = loaded
                .subscribe(onNext: { [weak self] _ in
                    self?.applyStyles(for: environment)
                })

            setStyleSubscription(subscription)
        }
    }
}
