import Foundation
import RxSwift

public struct StylizableStringArgument<Style, Properties>: StylizableStringComponentType {
    private let _builder: (Self.Locale, Style, @escaping (Style) -> Properties) -> Observable<NSAttributedString>

    public init<T: StylizableStringComponentType>(_ component: T) where T.Style == Style, T.Properties == Properties {
        _builder = component.buildAttributedString
    }

    public func buildAttributedString(locale: Self.Locale, style: Style, propertiesProvider: @escaping (Style) -> Properties) -> Observable<NSAttributedString> {
        _builder(locale, style, propertiesProvider)
    }
}

extension StylizableStringArgument where Properties: TextAttributesProviderType {
    public static func interpolated(_ string: StylizableString<Style, Properties>) -> Self {
        .init(string)
    }
}
