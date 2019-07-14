import UIKit
import RxSwift

public protocol BoldFontPropertiesProviderType {
    var fontForBoldText: UIFont { get }
}

public struct BoldStringModifier<Target: StylizableStringComponentType> {
    public typealias Style = Target.Style
    public typealias Properties = Target.Properties

    let target: Target

    init(target: Target) {
        self.target = target
    }
}

public extension StylizableStringComponentType {
    var bold: BoldStringModifier<Self> {
        BoldStringModifier(target: self)
    }
}

extension BoldStringModifier: StylizableStringComponentType where Target.Properties: BoldFontPropertiesProviderType {
    public func buildAttributedString(locale: String, style: Style, propertiesProvider: @escaping (Style) -> Properties) -> Observable<NSAttributedString> {
        let font = propertiesProvider(style).fontForBoldText
        return target.buildAttributedString(locale: locale, style: style, propertiesProvider: propertiesProvider).map { string in
            let mutable = NSMutableAttributedString(attributedString: string)
            mutable.addAttribute(.font, value: font, range: NSMakeRange(0, string.length))
            return mutable
        }
    }
}

public extension StylizableString.StringInterpolation where Properties: BoldFontPropertiesProviderType {
    mutating func appendInterpolation<Value: CustomStringConvertible>(bold value: Value) {
        appendComponent(ValueStringConvertible(value: value).bold)
    }

    mutating func appendInterpolation<Value: CustomStringConvertible>(bold observable: Observable<Value>) {
        appendComponent(ValueStringConvertible(valueObservable: observable.asObservable()).bold)
    }
}
