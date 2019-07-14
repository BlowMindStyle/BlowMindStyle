import Foundation
import RxSwift

struct StyleModifier<Target: StylizableStringComponentType>: StylizableStringComponentType {
    typealias Style = Target.Style
    typealias Properties = Target.Properties

    let style: Style
    let target: Target

    init(style: Style, target: Target) {
        self.style = style
        self.target = target
    }

    func buildAttributedString(locale: String, style: Style, propertiesProvider: @escaping (Style) -> Properties) -> Observable<NSAttributedString> {
        target.buildAttributedString(locale: locale, style: self.style, propertiesProvider: propertiesProvider)
    }
}


public extension StylizableString.StringInterpolation {
    mutating func appendInterpolation(style: Style, text: StylizableString) {
        appendComponent(StyleModifier(style: style, target: text))
    }
}


