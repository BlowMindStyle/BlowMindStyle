import Foundation
import RxSwift

@dynamicMemberLookup
public struct EnvironmentContext<Element, Environment: StyleEnvironmentConvertible> {
    public typealias StyleEnvironment = Environment.StyleEnvironment
    
    public let element: Element
    public let environment: Observable<Environment>
    public let appendSubscription: (Disposable) -> Void

    public init(element: Element, environment: Observable<Environment>, appendSubscription: @escaping (Disposable) -> Void) {
        self.element = element
        self.environment = environment
        self.appendSubscription = appendSubscription
    }

    public subscript<Child>(dynamicMember keyPath: KeyPath<Element, Child>) -> EnvironmentContext<Child, Environment> {
        EnvironmentContext<Child, Environment>(
            element: element[keyPath: keyPath],
            environment: environment,
            appendSubscription: appendSubscription
        )
    }
}

extension EnvironmentContext {
    public func replacingElement<OtherElement>(_ element: OtherElement) -> EnvironmentContext<OtherElement, Environment> {
        EnvironmentContext<OtherElement, Environment>(
            element: element, environment: environment, appendSubscription: appendSubscription
        )
    }

    public func map<T>(_ transform: (Element) -> T) -> EnvironmentContext<T, Environment> {
        EnvironmentContext<T, Environment>(
            element: transform(element), environment: environment, appendSubscription: appendSubscription
        )
    }

    public func mapEnvironment<T>(_ transform: @escaping (Environment) -> T) -> EnvironmentContext<Element, T> {
        EnvironmentContext<Element, T>(
            element: element, environment: environment.map(transform), appendSubscription: appendSubscription
        )
    }

    public func unwrapped<T>() -> EnvironmentContext<T, Environment>? where Element == Optional<T> {
        guard let element = element else { return nil }

        return EnvironmentContext<T, Environment>(
            element: element, environment: environment, appendSubscription: appendSubscription
        )
    }
}

extension EnvironmentContext where Element: TraitCollectionProviderType {

    public var styleEnvironment: Observable<StyleEnvironment> {
        Observable.combineLatest(environment, element.observableTraitCollection) { env, traitCollection in
            env.toStyleEnvironment(traitCollection)
        }
    }

    public func applyResources<Style: EnvironmentStyleType>(_ style: Style,_ apply: @escaping (Element, Style.Resources) -> Void)
        where Style.Environment == StyleEnvironment
    {
        stylableElement { element, _, resources in
            apply(element, resources)
        }.apply(style)
    }

}

extension EnvironmentContext where Element: AnyObject {
    public func setUpStyles<StateObservable: ObservableConvertibleType>(
        for state: StateObservable,
        setUp: @escaping (EnvironmentContext<Element, Environment>, StateObservable.Element) -> Void
    ) {
        var disposeBag = DisposeBag()

        state.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak element, environment] state in
                disposeBag = DisposeBag()

                guard let element = element else { return }
                
                _setUpStyles(environment: environment, element: element) { context in
                    setUp(context, state)
                }.disposed(by: disposeBag)
            })
            .disposed(by: self)
    }
}
