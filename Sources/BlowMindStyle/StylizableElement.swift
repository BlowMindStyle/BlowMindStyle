import RxSwift

public protocol StylizableElement {
    associatedtype Style: StyleType

    func apply(style: Style, resources: Style.Resources, isInitialApply: Bool)
}

public extension EnvironmentContext
    where Element: StylizableElement,
          Element.Style: EnvironmentStyleType,
          Element.Style.Environment == Environment {

    func apply(_ style: Element.Style = .default) -> Disposable {
        environment.enumerated()
            .subscribe(onNext: { [element = self.element] (index, env) in
                element.apply(
                    style: style,
                    resources: style.getResources(from: env),
                    isInitialApply: index == 0)
            })
    }
}
