import UIKit
import RxSwift

public protocol CompoundStylizableElementType: class {
    associatedtype Environment

    typealias Context = EnvironmentContext<Self, Environment>

    func applyStylesToChildComponents(_ context: Context)
}

public extension CompoundStylizableElementType {
    func applyStyles<ObservableEnvironment: ObservableConvertibleType>(for environment: ObservableEnvironment)
        -> Disposable where ObservableEnvironment.Element == Environment {
            var subscriptions: [Disposable] = []
            let context = EnvironmentContext(element: self, environment: environment.asObservable(), appendSubscription: { subscriptions.append($0) })
            applyStylesToChildComponents(context)
            return Disposables.create(subscriptions)
    }
}

public extension CompoundStylizableElementType where Self: StyleSubscriptionOwnerType {
    func applyStyles<ObservableEnvironment: ObservableConvertibleType>(for environment: ObservableEnvironment)
        where ObservableEnvironment.Element == Environment {
            setStyleSubscription(applyStyles(for: environment))
    }
}

public extension EnvironmentContext where Element: CompoundStylizableElementType, Element.Environment == Environment {
    func applyStyles() {
        appendSubscription(element.applyStyles(for: environment))
    }
}

public extension CompoundStylizableElementType where Self: UIViewController, Self: StyleSubscriptionOwnerType {
    func applyStylesOnLoad<ObservableEnvironment: ObservableConvertibleType>(for environment: ObservableEnvironment)
        where ObservableEnvironment.Element == Environment{
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
