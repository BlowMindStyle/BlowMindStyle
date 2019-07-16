import UIKit
import RxSwift

public protocol BoldFontPropertiesProviderType {
    var fontForBoldText: UIFont { get }
}

public struct BoldStringModifier<Target: StylizableStringComponentType> {
    public typealias Style = Target.Style
    public typealias Environment = Target.Environment

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
    public func buildAttributedString(style: Style, environment: Environment, getResources: @escaping (Style, Environment) -> Style.Resources) -> Observable<NSAttributedString> {
        let font = getResources(style, environment).fontForBoldText
        return target.buildAttributedString(style: style, environment: environment, getResources: getResources).map { string in
            let mutable = NSMutableAttributedString(attributedString: string)
            mutable.addAttribute(.font, value: font, range: NSMakeRange(0, string.length))
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

    mutating func appendInterpolation(bold arg: StylizableStringArgument<Style, Environment>) {
        appendComponent(arg.bold)
    }
}
