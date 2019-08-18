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

        public mutating func appendBuilder(_ builder: @escaping (Style, Style.Environment) -> Observable<NSAttributedString>) {
            builders.append(builder)
        }
    }

    private let builder: (Style, Style.Environment) -> Observable<NSAttributedString>

    public init(stringLiteral value: String) {
        builder = { _, _ in .just(NSAttributedString(string: value)) }
    }

    public init(_ string: StylizableString) {
        self = string
    }

    public init(stringInterpolation: StringInterpolation) {
        let builders = stringInterpolation.builders
        guard !builders.isEmpty else {
            builder = { _, _ in .just(NSAttributedString()) }
            return
        }

        builder = { style, env in
            Observable
                .combineLatest(builders.map { factory in
                    factory(style, env)
                })
                .map { attributedStrings in
                    let attributes = style.getResources(from: env).textAttributes
                    return AttributedStringBuilder.build(components: attributedStrings, attributes: attributes)
            }
        }
    }

    public init(builder: @escaping (Style, Style.Environment) -> Observable<NSAttributedString>) {
        self.builder = builder
    }

    public init<Component: StylizableStringComponentType>(component: Component) where Component.Style == Style {
        builder = component.buildAttributedString
    }

    public func buildAttributedString(style: Style, environment: Style.Environment) -> Observable<NSAttributedString> {
        builder(style, environment)
    }
}
