import Foundation
import RxSwift

public struct StylizableStringArgument<Style: StyleType, Environment>: StylizableStringComponentType {
    private let _builder: (Style, Environment, @escaping (Style, Environment) -> Style.Resources) -> Observable<NSAttributedString>

    public init<T: StylizableStringComponentType>(_ component: T) where T.Style == Style, T.Environment == Environment {
        _builder = component.buildAttributedString
    }

    public func buildAttributedString(style: Style, environment: Environment, getResources: @escaping (Style, Environment) -> Style.Resources) -> Observable<NSAttributedString> {
        _builder(style, environment, getResources)
    }
}

public extension StylizableStringArgument where Style.Resources: TextAttributesProviderType {
    static func text(_ string: StylizableString<Style, Environment>) -> Self {
        .init(string)
    }
}
