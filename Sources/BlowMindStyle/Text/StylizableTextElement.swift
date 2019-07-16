import UIKit
import RxSwift

public protocol StylizableTextElement {
    associatedtype Style: StyleType
    associatedtype Environment

    func apply(style: Style, resources: Style.Resources, environment: Environment, isInitialApply: Bool, text: NSAttributedString)
}

public extension EnvironmentContext
    where Element: StylizableTextElement,
          Element.Style: EnvironmentStyleType,
          Element.Style.Environment == Environment,
          Element.Environment == Environment,
          Element.Style.Resources: TextAttributesProviderType {

    func apply(_ style: Element.Style = .default, text: StylizableString<Element.Style, Environment>) -> Disposable {
        let environmentAndText = environment
            .flatMapLatest { env -> Observable<(Environment, NSAttributedString)> in
                text.buildAttributedString(
                    style: style,
                    environment: env,
                    getResources: { style, env in style.getResources(from: env) })
                    .map { (env, $0) }
        }

        return environmentAndText.enumerated()
            .subscribe(onNext: { [element = self.element] (index, tuple) in
                let (env, text) = tuple
                return element.apply(
                    style: style,
                    resources: style.getResources(from: env),
                    environment: env,
                    isInitialApply: index == 0,
                    text: text)
            })
    }
}
