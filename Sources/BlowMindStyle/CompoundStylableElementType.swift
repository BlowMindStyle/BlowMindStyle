import UIKit
import RxSwift

public protocol CompoundStylableElementType: class {
    associatedtype Environment: StyleEnvironmentConvertible = DefaultStyleEnvironmentConvertible

    typealias Context = EnvironmentContext<Self, Environment>

    func applyStylesToChildComponents(_ context: Context) -> Disposable
}

extension CompoundStylableElementType
    where
    Self: TraitCollectionProviderType
{
    public func applyStyles(for environment: Observable<Environment>) -> Disposable {
        applyStylesToChildComponents(.init(element: self, environment: environment))
    }
}

extension CompoundStylableElementType
    where
    Self: TraitCollectionProviderType,
    Environment == DefaultStyleEnvironmentConvertible
{
    public func applyStyles() -> Disposable {
        applyStyles(for: .just(.init()))
    }
}

extension CompoundStylableElementType
    where
    Self: TraitCollectionProviderType,
    Self: StyleSubscriptionOwnerType
{
    public func applyStyles(for environment: Observable<Self.Environment>) {
        setStyleSubscription(applyStyles(for: environment))
    }
}

extension CompoundStylableElementType
    where
    Self: TraitCollectionProviderType,
    Self: StyleSubscriptionOwnerType,
    Environment == DefaultStyleEnvironmentConvertible
{
    public func applyStyles() {
        applyStyles(for: .just(.init()))
    }
}

extension EnvironmentContext
    where
    Element: TraitCollectionProviderType,
    Element: CompoundStylableElementType,
    Element.Environment == Environment
{
    public func applyStyles() -> Disposable {
        element.applyStyles(for: environment)
    }
}

extension CompoundStylableElementType
    where
    Self: UIViewController,
    Self: StyleSubscriptionOwnerType
{
    public func applyStylesOnLoad(for environment: Observable<Self.Environment>) {
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
