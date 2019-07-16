import Foundation
import RxSwift

public struct StylizableStringArgument<Style: EnvironmentStyleType>: StylizableStringComponentType {
    private let _builder: (Style, Style.Environment) -> Observable<NSAttributedString>

    public init<T: StylizableStringComponentType>(_ component: T) where T.Style == Style {
        _builder = component.buildAttributedString
    }

    public func buildAttributedString(style: Style, environment: Style.Environment) -> Observable<NSAttributedString> {
        _builder(style, environment)
    }
}

public extension StylizableStringArgument where Style.Resources: TextAttributesProviderType {
    static func text(_ string: StylizableString<Style>) -> Self {
        .init(string)
    }
}
