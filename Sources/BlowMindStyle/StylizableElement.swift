import RxSwift

public protocol StylizableElement {
    associatedtype Style
    associatedtype Properties
    associatedtype Environment

    func apply(style: Style, properties: Properties, environment: Environment, isInitialApply: Bool)
}

struct StylizableElements {
}

public extension EnvironmentContext
    where Environment: ThemeEnvironmentType,
          Element: StylizableElement,
          Element.Style: ThemeStyleType,
          Element.Style.Properties == Element.Properties,
          Element.Style.Theme == Environment.Theme,
          Element.Environment == Environment {

    func apply(_ style: Element.Style = .default) -> Disposable {
        environment.enumerated()
            .subscribe(onNext: { [element = self.element] (index, env) in
                element.apply(
                    style: style,
                    properties: style.getProperties(from: env.theme),
                    environment: env,
                    isInitialApply: index == 0)
            })
    }
}
