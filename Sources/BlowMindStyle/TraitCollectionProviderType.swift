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

extension TraitCollectionProviderType {
    func _applyStyles<EnvironmentObservable: ObservableConvertibleType, Environment>(
        for environment: EnvironmentObservable,
        apply: (EnvironmentContext<Self, Environment>) -> Void
    ) -> Disposable
        where
        EnvironmentObservable.Element == Environment,
        Environment: StyleEnvironmentConvertible
    {
        var disposables: [Disposable] = []

        var applyStylesCompleted = false

        let context = EnvironmentContext(element: self, environment: environment.asObservable()) { disposable in
            guard !applyStylesCompleted else {
                assertionFailure("EnvironmentContext is not intended to reuse")

                disposable.dispose()
                return
            }

            disposables.append(disposable)
        }

        apply(context)
        applyStylesCompleted = true

        return Disposables.create(disposables)
    }
}

extension TraitCollectionProviderType where Self: StyleSubscriptionOwnerType {
    public func setUpStyles<EnvironmentObservable: ObservableConvertibleType, Environment>(
        with environment: EnvironmentObservable,
        _ setup: (EnvironmentContext<Self, Environment>) -> Void
    )
        where
        EnvironmentObservable.Element == Environment,
        Environment: StyleEnvironmentConvertible
    {
        disposeStyleSubscription()
        let subscription = _applyStyles(for: environment, apply: setup)
        setStyleSubscription(subscription)
    }

    public func setUpStyles(_ setup: (EnvironmentContext<Self, DefaultStyleEnvironmentConvertible>) -> Void) {
        setUpStyles(with: Observable.just(.init()), setup)
    }
}
