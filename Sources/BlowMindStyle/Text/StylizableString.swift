import Foundation
import RxSwift

public struct StylizableString<Style: TextStyleType>:
    ExpressibleByStringLiteral,
    ExpressibleByStringInterpolation,
    StylizableStringComponentType {

    public struct StringInterpolation: StringInterpolationProtocol {
        typealias Builder = (Style, Style.Environment) -> Observable<NSAttributedString>
        internal var builders: [Builder] = []

        public init(literalCapacity: Int, interpolationCount: Int) {
        }

        public mutating func appendLiteral(_ literal: String) {
            builders.append { _, _ in .just(NSAttributedString(string: literal)) }
        }

        public mutating func appendComponent<Component: StylizableStringComponentType>(_ component: Component)
            where Component.Style == Style {
                builders.append(component.buildAttributedString)
        }
    }

    private let componentsBuilder: (Style, Style.Environment) -> Observable<[NSAttributedString]>

    public init(stringLiteral value: String) {
        componentsBuilder = { _, _ in .just([NSAttributedString(string: value)]) }
    }

    public init(_ string: StylizableString) {
        self = string
    }

    public init(stringInterpolation: StringInterpolation) {
        let builders = stringInterpolation.builders
        guard !builders.isEmpty else {
            componentsBuilder = { _, _ in .just([NSAttributedString()]) }
            return
        }

        componentsBuilder = { style, env in
            Observable.combineLatest(builders.map { factory in
                factory(style, env)
            })
        }
    }

    public func buildAttributedString(style: Style, environment: Style.Environment) -> Observable<NSAttributedString> {
        componentsBuilder(style, environment).map { components in
            let attributes = style.getResources(from: environment).textAttributes
            return AttributedStringBuilder.build(components: components, attributes: attributes)
        }
    }
}
