import Foundation
import RxSwift

public struct StylizableString<Style: StyleType>:
    ExpressibleByStringLiteral,
    ExpressibleByStringInterpolation,
    StylizableStringComponentType
    where Style.Resources: TextAttributesProviderType {

    public struct StringInterpolation: StringInterpolationProtocol {
        typealias Builder = (StylizableStringComponentType.Locale, Style, @escaping (Style) -> Style.Resources) -> Observable<NSAttributedString>
        internal var builders: [Builder] = []

        public init(literalCapacity: Int, interpolationCount: Int) {
        }

        public mutating func appendLiteral(_ literal: String) {
            builders.append { _, _, _ in .just(NSAttributedString(string: literal)) }
        }

        public mutating func appendComponent<Component: StylizableStringComponentType>(_ component: Component)
            where Component.Style == Style {
                builders.append(component.buildAttributedString)
        }
    }

    private let componentsBuilder: (Self.Locale, Style, @escaping (Style) -> Style.Resources) -> Observable<[NSAttributedString]>

    public init(stringLiteral value: String) {
        componentsBuilder = { _, _, _ in .just([NSAttributedString(string: value)]) }
    }

    public init(_ string: StylizableString) {
        self = string
    }

    public init(stringInterpolation: StringInterpolation) {
        let builders = stringInterpolation.builders
        guard !builders.isEmpty else {
            componentsBuilder = { _, _, _ in .just([NSAttributedString()]) }
            return
        }

        componentsBuilder = { locale, style, getResources in
            Observable.combineLatest(builders.map { factory in
                factory(locale, style, getResources)
            })
        }
    }

    public func buildAttributedString(locale: Self.Locale, style: Style, getResources: @escaping (Style) -> Style.Resources) -> Observable<NSAttributedString> {
        componentsBuilder(locale, style, getResources).map { components in
            let attributes = getResources(style).textAttributes

            let result = NSMutableAttributedString()

            for component in components {
                let mutableCopy = NSMutableAttributedString(attributedString: component)
                var attributesToRestore: [(NSMutableAttributedString.Key, Any, NSRange)] = []
                for attr in attributes.keys {
                    component.enumerateAttribute(attr, in: NSMakeRange(0, component.length), options: []) { (value, range, _) in
                        guard let value = value else { return }
                        attributesToRestore.append((attr, value, range))
                    }
                }

                mutableCopy.addAttributes(attributes, range: NSMakeRange(0, component.length))
                for (key, value, range) in attributesToRestore {
                    mutableCopy.addAttribute(key, value: value, range: range)
                }
                result.append(mutableCopy)
            }

            return result
        }
    }
}
