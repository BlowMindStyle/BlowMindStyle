import RxSwift

public protocol StylizableElement {
    associatedtype Style: StyleType
    associatedtype Environment

    func apply(style: Style, resources: Style.Resources, environment: Environment, isInitialApply: Bool)
}

public extension EnvironmentContext
    where Environment: ThemeEnvironmentType,
          Element: StylizableElement,
          Element.Style: ThemeStyleType,
          Element.Style.Theme == Environment.Theme,
          Element.Environment == Environment {

    func apply(_ style: Element.Style = .default) -> Disposable {
        environment.enumerated()
            .subscribe(onNext: { [element = self.element] (index, env) in
                element.apply(
                    style: style,
                    resources: style.getResources(from: env.theme),
                    environment: env,
                    isInitialApply: index == 0)
            })
    }
}
