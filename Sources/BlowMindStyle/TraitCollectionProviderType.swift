import UIKit
import RxSwift
import RxCocoa

public protocol TraitCollectionProviderType {
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

    public func setUpStyles(_ setup: (EnvironmentContext<Self, DefaultStyleEnvironmentConvertible>) -> Void) {
        setUpStyles(with: Observable.just(.init()), setup: setup)
    }
}
