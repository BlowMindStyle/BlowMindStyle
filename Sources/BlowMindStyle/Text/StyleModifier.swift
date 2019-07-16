import Foundation
import RxSwift

struct StyleModifier<Target: StylizableStringComponentType>: StylizableStringComponentType {
    typealias Style = Target.Style
    typealias Environment = Target.Environment

    let style: Style
    let target: Target

    init(style: Style, target: Target) {
        self.style = style
        self.target = target
    }

    func buildAttributedString(style: Target.Style, environment: Environment, getResources: @escaping (Target.Style, Environment) -> Target.Style.Resources) -> Observable<NSAttributedString> {
        target.buildAttributedString(style: style, environment: environment, getResources: getResources)
    }
}

public extension StylizableString.StringInterpolation {
    mutating func appendInterpolation(style: Style, text: StylizableString) {
        appendComponent(StyleModifier(style: style, target: text))
    }

    mutating func appendInterpolation(style: Style, _ arg: StylizableStringArgument<Style, Environment>) {
        appendComponent(StyleModifier(style: style, target: arg))
    }
}
