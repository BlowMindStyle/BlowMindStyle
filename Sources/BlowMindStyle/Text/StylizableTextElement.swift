import UIKit
import RxSwift

public protocol StylizableTextElement {
    associatedtype Style: StyleType

    func apply(style: Style, resources: Style.Resources, isInitialApply: Bool, text: NSAttributedString)
}

public extension EnvironmentContext
    where Element: StylizableTextElement,
          Element.Style: SemanticStringStyleType,
          Element.Style.Environment == Environment,
          Environment: LocaleEnvironmentType {

    func apply(_ style: Element.Style, text: SemanticString) -> Disposable {
        let environmentAndText = environment
            .map { env -> (Environment, NSAttributedString) in
                (env, text.getAttributedString(for: style, environment: env))
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

    func apply<O: ObservableConvertibleType>(_ style: Element.Style, text: O) -> Disposable where O.E == SemanticString {
        let environmentAndText = Observable.combineLatest(environment, text.asObservable())
            .map { env, text -> (Environment, NSAttributedString) in
                (env, text.getAttributedString(for: style, environment: env))
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

public extension EnvironmentContext
    where Element: StylizableTextElement,
          Element.Style: SemanticStringStyleType,
          Element.Style: DefaultStyleType,
          Element.Style.Environment == Environment,
          Environment: LocaleEnvironmentType {

    func apply(text: SemanticString) -> Disposable {
        apply(.default, text: text)
    }

    func apply<O: ObservableConvertibleType>(text: O) -> Disposable where O.E == SemanticString  {
        apply(.default, text: text)
    }
}
