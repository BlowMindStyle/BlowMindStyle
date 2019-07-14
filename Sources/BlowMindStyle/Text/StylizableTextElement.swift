import UIKit
import RxSwift

public protocol StylizableTextElement {
    associatedtype Style
    associatedtype Properties
    associatedtype Environment

    func apply(style: Style, properties: Properties, environment: Environment, isInitialApply: Bool, text: NSAttributedString)
}

extension EnvironmentContext
    where Environment: ThemeEnvironmentType,
          Element: StylizableTextElement,
          Element.Style: ThemeStyleType,
          Element.Style.Properties == Element.Properties,
          Element.Style.Theme == Environment.Theme,
          Element.Environment == Environment,
          Environment: LocaleEnvironmentType,
          Element.Properties: TextAttributesProviderType {

    func apply(_ style: Element.Style = .default, text: StylizableString<Element.Style, Element.Properties>) -> Disposable {
        let environmentAndText = environment
            .flatMapLatest { env -> Observable<(Environment, NSAttributedString)> in
                text.buildAttributedString(
                    locale: env.locale,
                    style: style,
                    propertiesProvider: { style in style.getProperties(from: env.theme) })
                    .map { (env, $0) }
        }

        return environmentAndText.enumerated()
            .subscribe(onNext: { [element = self.element] (index, tuple) in
                let (env, text) = tuple
                return element.apply(
                    style: style,
                    properties: style.getProperties(from: env.theme),
                    environment: env,
                    isInitialApply: index == 0,
                    text: text)
            })
    }
}
