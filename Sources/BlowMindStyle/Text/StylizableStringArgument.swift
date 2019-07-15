import Foundation
import RxSwift

public struct StylizableStringArgument<Style: StyleType>: StylizableStringComponentType {
    private let _builder: (Self.Locale, Style, @escaping (Style) -> Style.Resources) -> Observable<NSAttributedString>

    public init<T: StylizableStringComponentType>(_ component: T) where T.Style == Style {
        _builder = component.buildAttributedString
    }

    public func buildAttributedString(locale: Self.Locale, style: Style, getResources: @escaping (Style) -> Style.Resources) -> Observable<NSAttributedString> {
        _builder(locale, style, getResources)
    }
}

public extension StylizableStringArgument where Style.Resources: TextAttributesProviderType {
    static func interpolated(_ string: StylizableString<Style>) -> Self {
        .init(string)
    }
}
