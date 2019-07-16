import Foundation
import RxSwift

public struct StylizableStringArgument<Style: TextStyleType> {
    internal let builder: (Style, Style.Environment) -> Observable<NSAttributedString>
    internal let skipRendering: Bool

    public init<T: StylizableStringComponentType>(_ component: T) where T.Style == Style {
        builder = component.buildAttributedString
        skipRendering = false
    }

    public init<T: StylizableStringComponentType>(_ component: T, skipRendering: Bool) where T.Style == Style {
        builder = component.buildAttributedString
        self.skipRendering = skipRendering
    }
}

public extension StylizableStringArgument where Style.Resources: TextAttributesProviderType {
    static func text(_ string: StylizableString<Style>) -> Self {
        .init(string, skipRendering: true)
    }
}

internal struct StylizableStringArgumentRenderer<Style: TextStyleType>: StylizableStringComponentType {
    private let arg: StylizableStringArgument<Style>
    init(arg: StylizableStringArgument<Style>) {
        self.arg = arg
    }

    public func buildAttributedString(style: Style, environment: Style.Environment) -> Observable<NSAttributedString> {
        guard !arg.skipRendering else { return arg.builder(style, environment) }

        let attributes = style.getResources(from: environment).textAttributes

        return arg.builder(style, environment).map { string in
            AttributedStringBuilder.build(components: [string], attributes: attributes)
        }
    }
}

extension StylizableStringArgument {
    var renderer: StylizableStringArgumentRenderer<Style> {
        StylizableStringArgumentRenderer(arg: self)
    }
}
