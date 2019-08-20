import Foundation
import RxSwift

struct StyleModifier<Target: StylizableStringComponentType>: StylizableStringComponentType {
    typealias Style = Target.Style

    let style: Style
    let target: Target

    init(style: Style, target: Target) {
        self.style = style
        self.target = target
    }

    func buildAttributedString(style: Target.Style, environment: Style.Environment) -> Observable<NSAttributedString> {
        target.buildAttributedString(style: self.style, environment: environment)
    }
}

public extension StylizableString.StringInterpolation {
    mutating func appendInterpolation(style: Style, text: StylizableString) {
        appendComponent(StyleModifier(style: style, target: text))
    }
}

public extension StylizableString.StringInterpolation where Style: SemanticStringStyleType, Style.Environment: LocaleEnvironmentType {
    mutating func appendInterpolation(style: Style, semantic string: SemanticString) {
        appendComponent(StyleModifier(style: style, target: StylizableString(semantic: string)))
    }
}
