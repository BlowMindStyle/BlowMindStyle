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

    func buildAttributedString(locale: Self.Locale, style: Style, getResources: @escaping (Style) -> Style.Resources) -> Observable<NSAttributedString> {
        target.buildAttributedString(locale: locale, style: self.style, getResources: getResources)
    }
}

public extension StylizableString.StringInterpolation {
    mutating func appendInterpolation(style: Style, text: StylizableString) {
        appendComponent(StyleModifier(style: style, target: text))
    }

    mutating func appendInterpolation(style: Style, _ arg: StylizableStringArgument<Style>) {
        appendComponent(StyleModifier(style: style, target: arg))
    }
}
