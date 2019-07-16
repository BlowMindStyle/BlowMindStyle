import UIKit
import RxSwift

public protocol StylizableTextElement {
    associatedtype Style: StyleType

    func apply(style: Style, resources: Style.Resources, isInitialApply: Bool, text: NSAttributedString)
}

public extension EnvironmentContext
    where Element: StylizableTextElement,
          Element.Style: TextStyleType,
          Element.Style.Environment == Environment {

    func apply(_ style: Element.Style = .default, text: StylizableString<Element.Style>) -> Disposable {
        let environmentAndText = environment
            .flatMapLatest { env -> Observable<(Environment, NSAttributedString)> in
                text.buildAttributedString(style: style, environment: env).map { (env, $0) }
        }

        return environmentAndText.enumerated()
            .subscribe(onNext: { [element = self.element] (index, tuple) in
                let (env, text) = tuple
                return element.apply(
                    style: style,
                    resources: style.getResources(from: env),
                    isInitialApply: index == 0,
                    text: text)
            })
    }
}
