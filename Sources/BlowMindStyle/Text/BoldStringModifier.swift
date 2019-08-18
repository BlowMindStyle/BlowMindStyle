import UIKit
import RxSwift

public protocol BoldFontPropertiesProviderType {
    var fontForBoldText: UIFont? { get }
    var foregroundForBoldText: UIColor? { get }
}

public struct BoldStringModifier<Target: StylizableStringComponentType> {
    public typealias Style = Target.Style

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

extension BoldStringModifier: StylizableStringComponentType where Style.Resources: BoldFontPropertiesProviderType {
    public func buildAttributedString(style: Style, environment: Style.Environment) -> Observable<NSAttributedString> {
        let resources = style.getResources(from: environment)
        let font = resources.fontForBoldText
        let foregroundColor = resources.foregroundForBoldText

        return target.buildAttributedString(style: style, environment: environment).map { string in
            let mutable = NSMutableAttributedString(attributedString: string)
            if let font = font {
                mutable.addAttribute(.font, value: font, range: NSMakeRange(0, string.length))
            }

            if let color = foregroundColor {
                mutable.addAttribute(.foregroundColor, value: color, range: NSMakeRange(0, string.length))
            }

            return mutable
        }
    }
}

public extension StylizableString.StringInterpolation where Style.Resources: BoldFontPropertiesProviderType {
    mutating func appendInterpolation<Value: CustomStringConvertible>(bold value: Value) {
        appendComponent(ValueStringConvertible(value: value).bold)
    }

    mutating func appendInterpolation<Value: CustomStringConvertible>(bold observable: Observable<Value>) {
        appendComponent(ValueStringConvertible(valueObservable: observable.asObservable()).bold)
    }
}
