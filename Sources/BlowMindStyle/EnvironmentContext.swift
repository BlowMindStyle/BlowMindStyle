import Foundation
import RxSwift

/**
 A type that provides context info for stylization – element (view), environment and function that stores style subscription.
 */
@dynamicMemberLookup
public struct EnvironmentContext<Element, Environment: StyleEnvironmentConvertible> {
    public typealias StyleEnvironment = Environment.StyleEnvironment

    /**
     the element that can be used for stylization
     */
    public let element: Element
    /**
     the observable environment
     */
    public let environment: Observable<Environment>
    /**
     stores a subscription.
     */
    public let appendSubscription: (Disposable) -> Void

    public init(element: Element, environment: Observable<Environment>, appendSubscription: @escaping (Disposable) -> Void) {
        self.element = element
        self.environment = environment
        self.appendSubscription = appendSubscription
    }

    /**
     creates environment context for child object

     ```
     context.button.buttonStyle.apply(style: .primary)
     // context – EnvironmentContext with Element = MyController. MyController has property 'let button = UIButton(type: .custom)`
     // context.button – EnvironmentContext with Element = UIButton.
     ```
     */
    public subscript<Child>(dynamicMember keyPath: KeyPath<Element, Child>) -> EnvironmentContext<Child, Environment> {
        EnvironmentContext<Child, Environment>(
            element: element[keyPath: keyPath],
            environment: environment,
            appendSubscription: appendSubscription
        )
    }
}

extension EnvironmentContext {
    /**
     creates `EnvironmentContext` from the current one with the replaced element.
     */
    public func replacingElement<OtherElement>(_ element: OtherElement) -> EnvironmentContext<OtherElement, Environment> {
        EnvironmentContext<OtherElement, Environment>(
            element: element, environment: environment, appendSubscription: appendSubscription
        )
    }

    /**
     creates `EnvironmentContext` with the transformed element.
     */
    public func map<T>(_ transform: (Element) -> T) -> EnvironmentContext<T, Environment> {
        EnvironmentContext<T, Environment>(
            element: transform(element), environment: environment, appendSubscription: appendSubscription
        )
    }

    /**
     creates `EnvironmentContext` with the transformed environment.
     */
    public func mapEnvironment<T>(_ transform: @escaping (Environment) -> T) -> EnvironmentContext<Element, T> {
        EnvironmentContext<Element, T>(
            element: element, environment: environment.map(transform), appendSubscription: appendSubscription
        )
    }

    /**
     converts `EnvironmentContext<T?, Environment>` to `EnvironmentContext<T, Environment>?`
     */
    public func unwrapped<T>() -> EnvironmentContext<T, Environment>? where Element == Optional<T> {
        guard let element = element else { return nil }

        return EnvironmentContext<T, Environment>(
            element: element, environment: environment, appendSubscription: appendSubscription
        )
    }
}

extension EnvironmentContext where Element: TraitCollectionProviderType {

    /**
     creates observable environment using `self.environment` and `observableTraitCollection` from `element`.
     `StyleEnvironment` type conforms to `StyleEnvironmentType`
     */
    public var styleEnvironment: Observable<StyleEnvironment> {
        Observable.combineLatest(environment, element.observableTraitCollection) { env, traitCollection in
            env.toStyleEnvironment(traitCollection)
        }
    }

    /**
     provides the ability to get resources from specified style.

     The normal way to use styles is to add an extension to `EnvironmentContext` with a constraint on Element type like
     ```
     extension EnvironmentContext where Element: UIButton {
         var buttonStyle: StylableElement<ButtonStyle<StyleEnvironment>> {
             stylableElement { button, style, resources in
                ...
         }
     }

     // context.button.buttonStyle.apply(.primary)
     ```
     but sometimes we want to get resources provided by specific style directly
     ```
     context.applyResources(ButtonStyle.primary) { viewController, buttonResources in
         ...
     }
     ```
     */
    public func applyResources<Style: EnvironmentStyleType>(_ style: Style,_ apply: @escaping (Element, Style.Resources) -> Void)
        where Style.Environment == StyleEnvironment
    {
        stylableElement { element, _, resources in
            apply(element, resources)
        }.apply(style)
    }

}

extension EnvironmentContext where Element: AnyObject {
    /**
     provides a way to re-setup after a state change
     */
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
