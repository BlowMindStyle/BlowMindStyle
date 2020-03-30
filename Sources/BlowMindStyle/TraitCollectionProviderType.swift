import UIKit
import RxSwift
import RxCocoa

/**
 Specifies the requirements to elements that have a trait collection.
 `UIView` and `UIViewController` conforms to it.
 */
public protocol TraitCollectionProviderType {
    /**
     - Returns: observable of `UITraitCollection`. On subscription returns current traitCollection. Emits new traitCollection on `traitCollectionDidChange(_:)`
     */
    var observableTraitCollection: Observable<UITraitCollection> { get }
}

extension UITraitEnvironment where Self: NSObject {
    public var observableTraitCollection: Observable<UITraitCollection> {
        .deferred { [weak self] in
            guard let self = self else { return .empty() }
            
            return self.rx
                .methodInvoked(#selector(UITraitEnvironment.traitCollectionDidChange))
                .map { [unowned self] args in self.traitCollection }
            .startWith(self.traitCollection)
        }
    }
}

extension UIViewController: TraitCollectionProviderType { }
extension UIView: TraitCollectionProviderType { }

func _setUpStyles<EnvironmentObservable: ObservableConvertibleType, Environment, Element>(
    environment: EnvironmentObservable,
    element: Element,
    setup: (EnvironmentContext<Element, Environment>) -> Void
) -> Disposable
    where
    EnvironmentObservable.Element == Environment,
    Environment: StyleEnvironmentConvertible
{
    var disposables: [Disposable] = []

    var applyStylesCompleted = false

    let context = EnvironmentContext(element: element, environment: environment.asObservable()) { disposable in
        guard !applyStylesCompleted else {
            assertionFailure("EnvironmentContext is not intended to reuse")

            disposable.dispose()
            return
        }

        disposables.append(disposable)
    }

    setup(context)
    applyStylesCompleted = true

    return Disposables.create(disposables)
}

extension NSObjectProtocol {
    /**
     Set up styles for the current element or its children.

     ```
     let disposable = viewController.setUpStyles(with: appEnvironment) {
        $0.view.backgroundStyle.apply()
        $0.button.apply(style: .primary)
     }
     ```

     - Parameters:
        - environment: observable environment.
        - setup: the function that contains logic for setting up styles for current element or children.

     - Returns: style subscription. If the subscription will be disposed, the style would not be updated on an environment change.
     */
    public func setUpStyles<EnvironmentObservable: ObservableConvertibleType, Environment>(
        with environment: EnvironmentObservable,
        setup: (EnvironmentContext<Self, Environment>) -> Void
    ) -> Disposable
        where
        EnvironmentObservable.Element == Environment,
        Environment: StyleEnvironmentConvertible
    {
        _setUpStyles(environment: environment, element: self, setup: setup)
    }
}

extension NSObjectProtocol where Self: StyleSubscriptionOwnerType {
    /**
     Set up styles for the current element or its children.

     ```
     viewController.setUpStyles(with: appEnvironment) {
        $0.view.backgroundStyle.apply()
        $0.button.apply(style: .primary)
     }
     ```

     - Parameters:
        - environment: observable environment.
        - setup: the function that contains logic for setting up styles for current element or children.

     This method disposes previous style subscription and stores new subscription using `StyleSubscriptionOwnerType.setStyleSubscription(_:)`
     */
    public func setUpStyles<EnvironmentObservable: ObservableConvertibleType, Environment>(
        with environment: EnvironmentObservable,
        setup: (EnvironmentContext<Self, Environment>) -> Void
    )
        where
        EnvironmentObservable.Element == Environment,
        Environment: StyleEnvironmentConvertible
    {
        disposeStyleSubscription()
        let subscription = _setUpStyles(environment: environment, element: self, setup: setup)
        setStyleSubscription(subscription)
    }

    /**
     Set up styles for the current element or its children.
     This method uses `DefaultStyleEnvironmentConvertible` that doesn't have a theme.
     The element will be updated only on `UITraitCollection` change.

     ```
     viewController.setUpStyles {
        $0.view.backgroundStyle.apply()
        $0.button.apply(style: .primary)
     }
     ```

     - Parameters:
        - setup: the function that contains logic for setting up styles for current element or children.

     This method disposes previous style subscription and stores new subscription using `StyleSubscriptionOwnerType.setStyleSubscription(_:)`
     */
    public func setUpStyles(_ setup: (EnvironmentContext<Self, DefaultStyleEnvironmentConvertible>) -> Void) {
        setUpStyles(with: Observable.just(.init()), setup: setup)
    }
}
