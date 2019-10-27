import RxSwift

public protocol StylizableElement {
    associatedtype Style: StyleType

    func apply(style: Style, resources: Style.Resources)
}

public struct StylizableElements { }

public extension EnvironmentContext
    where Element: StylizableElement,
          Element.Style: EnvironmentStyleType,
          Element.Style.Environment == Environment {

    func apply(_ style: Element.Style) -> Disposable {
        style.filteredEnvironment(environment)
            .subscribe(onNext: { [element = self.element] env in
                element.apply(
                    style: style,
                    resources: style.getResources(from: env)
                )
            })
    }

    func apply<ObservableState: ObservableConvertibleType, State>(
        forState state: ObservableState,
        _ styleSelector: @escaping (State) -> Element.Style)
        -> Disposable
        where ObservableState.Element == State {
            state.asObservable()
                .flatMapLatest { [environment] state -> Observable<(Element.Style, Environment)> in
                    let style = styleSelector(state)
                    return style.filteredEnvironment(environment).map { (style, $0) }
            }
            .subscribe(onNext: { [element = self.element] (style, env) in
                element.apply(style: style, resources: style.getResources(from: env))
            })
    }
}

public extension EnvironmentContext
    where Element: StylizableElement,
          Element.Style: EnvironmentStyleType,
          Element.Style: DefaultStyleType,
          Element.Style.Environment == Environment {

    func apply() -> Disposable {
        apply(.default)
    }
}
