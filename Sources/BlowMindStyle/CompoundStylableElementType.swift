import UIKit
import RxSwift

/**
 A type that can apply styles to child elements (views)
 */
public protocol CompoundStylableElementType: StyleSubscriptionOwnerType {
    associatedtype Environment: StyleEnvironmentConvertible = DefaultStyleEnvironmentConvertible

    typealias Context = EnvironmentContext<Self, Environment>

    /**
     applies styles to self and child elements.

     ```
     context.view.backgroundStyle.apply()
     context.button.apply(style: .primary)
     ```
     */
    func applyStylesToChildComponents(_ context: Context)
}

extension CompoundStylableElementType {
    private func _applyStyles<EnvironmentObservable: ObservableConvertibleType>(
        for environment: EnvironmentObservable,
        additionalDisposables: [Disposable] = []
    )
        where EnvironmentObservable.Element == Environment
    {
        disposeStyleSubscription()

        let subscription = _setUpStyles(environment: environment, element: self) { context in
            applyStylesToChildComponents(context)
        }

        setStyleSubscription(Disposables.create(additionalDisposables + [subscription]))
    }

    /**
     applies styles for the specified environment
     */
    public func applyStyles<EnvironmentObservable: ObservableConvertibleType>(
        for environment: EnvironmentObservable)
        where EnvironmentObservable.Element == Environment
    {
        _applyStyles(for: environment)
    }
}

extension CompoundStylableElementType
    where
    Self: TraitCollectionProviderType,
    Self: EnvironmentRepeaterType
{
    /**
     applies styles for the specified environment and emits environment to `environmentRelay`
     */
    public func applyStyles<EnvironmentObservable: ObservableConvertibleType>(
        for environment: EnvironmentObservable)
        where EnvironmentObservable.Element == Environment
    {
        let sharedEnvironment = environment.asObservable().share(replay: 1)

        let disposable = sharedEnvironment.subscribe(onNext: { [relay = environmentRelay] env in
            relay.accept(env)
        })

        _applyStyles(for: sharedEnvironment, additionalDisposables: [disposable])
    }
}

extension CompoundStylableElementType
    where
    Self: TraitCollectionProviderType,
    Environment == DefaultStyleEnvironmentConvertible
{
    public func applyStyles() {
        applyStyles(for: Observable.just(.init()))
    }
}

extension CompoundStylableElementType
    where
    Self: TraitCollectionProviderType,
    Environment == DefaultStyleEnvironmentConvertible,
    Self: EnvironmentRepeaterType
{
    public func applyStyles() {
        applyStyles(for: Observable.just(.init()))
    }
}

extension EnvironmentContext
    where
    Element: TraitCollectionProviderType,
    Element: CompoundStylableElementType,
    Element.Environment == Environment
{
    /**
     applies style to `CompoundStylableElementType`
     */
    public func applyStyles() {
        element.applyStyles(for: environment)
    }
}

extension EnvironmentContext
    where
    Element: TraitCollectionProviderType,
    Element: CompoundStylableElementType,
    Element.Environment == Environment,
    Element: EnvironmentRepeaterType
{
    /**
    applies style to `CompoundStylableElementType & EnvironmentRepeaterType`
    */
    public func applyStyles() {
        element.applyStyles(for: environment)
    }
}

extension CompoundStylableElementType
    where
    Self: UIViewController
{
    private func _applyStylesOnLoad<EnvironmentObservable: ObservableConvertibleType>(
        for environment: EnvironmentObservable,
        apply: @escaping (Self, EnvironmentObservable) -> Void
    )
        where EnvironmentObservable.Element == Self.Environment
    {
        if viewIfLoaded != nil {
            apply(self, environment)
        } else {
            let loaded = rx.methodInvoked(#selector(UIViewController.viewDidLoad)).take(1)

            let subscription = loaded
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    apply(self, environment)
                })

            setStyleSubscription(subscription)
        }
    }

    /**
     applies styles after UIViewController loading
     */
    public func applyStylesOnLoad<EnvironmentObservable: ObservableConvertibleType>(for environment: EnvironmentObservable)
        where EnvironmentObservable.Element == Self.Environment {
            _applyStylesOnLoad(for: environment, apply: { $0.applyStyles(for: $1) })
    }
}

extension CompoundStylableElementType
    where
    Self: UIViewController,
    Self: EnvironmentRepeaterType
{
    /**
     applies styles after UIViewController loading when Self: EnvironmentRepeaterType
     */
    public func applyStylesOnLoad<EnvironmentObservable: ObservableConvertibleType>(for environment: EnvironmentObservable)
        where EnvironmentObservable.Element == Self.Environment {
            _applyStylesOnLoad(for: environment, apply: { $0.applyStyles(for: $1) })
    }
}
