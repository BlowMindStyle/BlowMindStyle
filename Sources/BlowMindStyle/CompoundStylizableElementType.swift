import UIKit
import RxSwift

public protocol CompoundStylizableElementType: class {
    associatedtype Environment: StyleEnvironmentConvertible = DefaultStyleEnvironmentConvertible

    typealias Context = EnvironmentContext<Self, Environment.StyleEnvironment>

    func applyStylesToChildComponents(_ context: Context) -> Disposable
}

public extension CompoundStylizableElementType where Self: TraitCollectionProviderType {
    func applyStyles(for environment: Observable<Environment>) -> Disposable {
        let styleEnvironment = Observable.combineLatest(environment, observableTraitCollection, resultSelector: { env, traitCollection in
            env.toStyleEnvironment(traitCollection)
        })

        return applyStylesToChildComponents(.init(element: self, environment: styleEnvironment))
    }
}

public extension CompoundStylizableElementType where Self: TraitCollectionProviderType, Environment == DefaultStyleEnvironmentConvertible {
    func applyStyles() -> Disposable {
        applyStyles(for: .just(.init()))
    }
}

public extension CompoundStylizableElementType where Self: TraitCollectionProviderType, Self: StyleSubscriptionOwnerType {
    func applyStyles(for environment: Observable<Self.Environment>) {
        setStyleSubscription(applyStyles(for: environment))
    }
}

public extension CompoundStylizableElementType where Self: TraitCollectionProviderType, Self: StyleSubscriptionOwnerType, Environment == DefaultStyleEnvironmentConvertible {
    func applyStyles() {
        applyStyles(for: .just(.init()))
    }
}

public extension EnvironmentContext where Element: TraitCollectionProviderType, Element: CompoundStylizableElementType, Element.Environment == Environment {
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
