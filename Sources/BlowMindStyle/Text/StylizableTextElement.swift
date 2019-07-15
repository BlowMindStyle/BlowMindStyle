import UIKit
import RxSwift

public protocol StylizableTextElement {
    associatedtype Style: StyleType
    associatedtype Environment

    func apply(style: Style, resources: Style.Resources, environment: Environment, isInitialApply: Bool, text: NSAttributedString)
}

public extension EnvironmentContext
    where Environment: ThemeEnvironmentType,
          Element: StylizableTextElement,
          Element.Style: ThemeStyleType,
          Element.Style.Theme == Environment.Theme,
          Element.Environment == Environment,
          Environment: LocaleEnvironmentType,
          Element.Style.Resources: TextAttributesProviderType {

    func apply(_ style: Element.Style = .default, text: StylizableString<Element.Style>) -> Disposable {
        let environmentAndText = environment
            .flatMapLatest { env -> Observable<(Environment, NSAttributedString)> in
                text.buildAttributedString(
                    locale: env.locale,
                    style: style,
                    getResources: { style in style.getResources(from: env.theme) })
                    .map { (env, $0) }
        }

        return environmentAndText.enumerated()
            .subscribe(onNext: { [element = self.element] (index, tuple) in
                let (env, text) = tuple
                return element.apply(
                    style: style,
                    resources: style.getResources(from: env.theme),
                    environment: env,
                    isInitialApply: index == 0,
                    text: text)
            })
    }
}
