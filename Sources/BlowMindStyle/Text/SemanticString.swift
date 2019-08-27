import Foundation
import RxSwift

public protocol SemanticStringStyleType: TextStyleType {
    func getResources(from environment: Environment, for textStyle: SemanticString.TextStyle) -> Resources?
}

public protocol SemanticStringAttributesProviderType {
    var localeInfo: LocaleInfoType { get }
    func getAttributes(for textStyle: SemanticString.TextStyle?) -> [NSAttributedString.Key: Any]?
}

public struct SemanticStringAttributesProvider: SemanticStringAttributesProviderType {

    private let _getAttributes: (SemanticString.TextStyle?) -> [NSAttributedString.Key: Any]?
    public let localeInfo: LocaleInfoType

    public init<Style: SemanticStringStyleType>(style: Style, environment: Style.Environment) where Style.Environment: LocaleEnvironmentType {
        localeInfo = environment.localeInfo

        _getAttributes = { semanticStringStyle in
            if let semanticStringStyle = semanticStringStyle {
                return style.getResources(from: environment, for: semanticStringStyle)?.textAttributes
            } else {
                return style.getResources(from: environment).textAttributes
            }
        }
    }

    public init(localeInfo: LocaleInfoType, getAttributes: @escaping (SemanticString.TextStyle?) -> [NSAttributedString.Key: Any]?) {
        self.localeInfo = localeInfo
        _getAttributes = getAttributes
    }

    public func getAttributes(for textStyle: SemanticString.TextStyle?) -> [NSAttributedString.Key: Any]? {
        _getAttributes(textStyle)
    }

    public static var `default`: SemanticStringAttributesProvider {
        SemanticStringAttributesProvider(localeInfo: LocaleInfo.system, getAttributes: { _ in nil })
    }
}

public struct SemanticString {
    let components: [StringComponent]
}

extension SemanticString: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    public struct StringInterpolation: StringInterpolationProtocol {
        var components: [SemanticString.StringComponent] = []

        public init(literalCapacity: Int, interpolationCount: Int) {
            components.reserveCapacity(interpolationCount)
        }

        public mutating func appendLiteral(_ literal: String) {
            components.append(.init(styles: [], content: .plain(literal)))
        }

        public mutating func appendInterpolation(resource: StringResourceType, args: CVarArg...) {
            components.append(.init(styles: [], content: .localizable(resource, args)))
        }

        public mutating func appendInterpolation(resource: StringResourceType, argsArray: [CVarArg]) {
            components.append(.init(styles: [], content: .localizable(resource, argsArray)))
        }

        public mutating func appendInterpolation(_ string: SemanticString) {
            components.append(contentsOf: string.components)
        }

        public mutating func appendInterpolation(_ string: NSAttributedString) {
            components.append(.init(styles: [], content: .attributed(string)))
        }

        public mutating func appendInterpolation(style: TextStyle, _ string: SemanticString) {
            for component in string.components {
                components.append(.init(styles: [style] + component.styles, content: component.content))
            }
        }

        public mutating func appendInterpolation(styles: [TextStyle], _ string: SemanticString) {
            for component in string.components {
                components.append(.init(styles: styles + component.styles, content: component.content))
            }
        }

        public mutating func appendInterpolation<Value: CustomStringConvertible>(_ value: Value) {
            components.append(.init(styles: [], content: .plain(value.description)))
        }
    }

    public init(stringLiteral value: String) {
        components = [.init(styles: [], content: .plain(value))]
    }

    public init(stringInterpolation: StringInterpolation) {
        components = stringInterpolation.components
    }

    public init(resource: StringResourceType, args: CVarArg..., styles: [TextStyle] = []) {
        components = [.init(styles: styles, content: .localizable(resource, args))]
    }

    public init(resource: StringResourceType, argsArray: [CVarArg], styles: [TextStyle] = []) {
        components = [.init(styles: styles, content: .localizable(resource, argsArray))]
    }

    public init(_ string: SemanticString) {
        components = string.components
    }

    public init(string: String) {
        components = [.init(styles: [], content: .plain(string))]
    }

    public init(dynamic provider: @escaping (LocaleInfoType) -> SemanticString, styles: [TextStyle] = []) {
        components = [.init(styles: styles, content: .dynamic(provider))]
    }

    public init(_ attributedString: NSAttributedString, styles: [TextStyle] = []) {
        components = [.init(styles: styles, content: .attributed(attributedString))]
    }
}

public extension SemanticString {
    struct TextStyle: Hashable, Equatable, RawRepresentable {
        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension SemanticString {
    struct StringComponent {
        let styles: [TextStyle]
        let content: Content
    }

    enum Content {
        case plain(String)
        case attributed(NSAttributedString)
        case localizable(StringResourceType, [CVarArg])
        case dynamic((LocaleInfoType) -> SemanticString)
    }
}

extension SemanticString {
    public func getString(_ localeInfo: LocaleInfoType) -> String {
        let strings = components.map { component in
            getString(component: component, localeInfo: localeInfo)
        }

        return strings.joined()
    }

    public func getString() -> String {
        return getString(DefaultLocaleInfo())
    }

    private func getString(component: StringComponent, localeInfo: LocaleInfoType) -> String {
        switch component.content {
        case let .plain(string):
            return string

        case let .attributed(attributedString):
            return attributedString.string

        case let .localizable(resource, args):
            let format = localeInfo.localize(resource)
            return String(format: format, arguments: args)

        case let .dynamic(provider):
            return provider(localeInfo).getString(localeInfo)
        }
    }
}

extension SemanticString {
    public func getAttributedString(provider: SemanticStringAttributesProviderType) -> NSAttributedString {
        let commonAttributes = provider.getAttributes(for: nil) ?? [:]

        let localeInfo = provider.localeInfo

        let strings = components.map { component in
            getAttributedString(
                component: component,
                localeInfo: localeInfo,
                getAttributes: { textStyle in provider.getAttributes(for: textStyle)  })
        }

        let resultString = AttributedStringBuilder.build(components: strings, attributes: commonAttributes)
        return resultString
    }

    public func getAttributedString<Style: SemanticStringStyleType>(
        for style: Style, environment: Style.Environment) -> NSAttributedString
        where Style.Environment: LocaleEnvironmentType {
            getAttributedString(provider: SemanticStringAttributesProvider(style: style, environment: environment))
    }

    private func getAttributedString(
        component: StringComponent,
        localeInfo: LocaleInfoType,
        getAttributes: (TextStyle) -> [NSAttributedString.Key: Any]?)
        -> NSAttributedString {
            let attributedString = getAttributedString(
                content: component.content, localeInfo: localeInfo, getAttributes: getAttributes)

            var attributes: [NSAttributedString.Key: Any] = [:]
            for style in component.styles {
                guard let attributesForStyle = getAttributes(style) else { continue }
                for (key, value) in attributesForStyle {
                    attributes[key] = value
                }
            }

            guard !attributes.isEmpty else { return attributedString }
            let attributedStringWithAppliedStyles = AttributedStringBuilder.build(
                components: [attributedString], attributes: attributes)

            return attributedStringWithAppliedStyles
    }

    private func getAttributedString(
        content: Content,
        localeInfo: LocaleInfoType,
        getAttributes: (TextStyle) -> [NSAttributedString.Key: Any]?)
        -> NSAttributedString {

            switch content {
            case let .plain(string):
                return NSAttributedString(string: string)

            case let .attributed(string):
                return string

            case let .localizable(resource, args):
                let format = localeInfo.localize(resource)
                let string = String(format: format, arguments: args)
                return NSAttributedString(string: string)

            case let .dynamic(provider):
                let semanticString = provider(localeInfo)
                let strings = semanticString.components.map { component in
                    getAttributedString(component: component, localeInfo: localeInfo, getAttributes: getAttributes)
                }

                return AttributedStringBuilder.build(components: strings, attributes: [:])
            }
    }
}

public extension SemanticString {
    init(xml string: SemanticString) {
        let content: Content = .dynamic { localeInfo in
            SemanticString.parseXmlSemanticString(string, localeInfo: localeInfo)
        }

        self.components = [StringComponent(styles: [], content: content)]
    }

    private static func parseXmlSemanticString(_ semanticString: SemanticString, localeInfo: LocaleInfoType) -> SemanticString {
        let flatStringComponents = semanticString.components.flatMap { $0.mapToFlatStringComponent(localeInfo: localeInfo) }
        let tagMatches = flatStringComponents.enumerated()
            .flatMap { (index, component) in component.content.getTags(componentIndex: index) }

        var openedTags: [TagMatch] = []
        var balandedTags: [(opening: TagMatch, closing: TagMatch)] = []
        for tagMatch in tagMatches {
            if tagMatch.isOpening {
                openedTags.append(tagMatch)
            } else {
                if let openingTagIndex = openedTags.lastIndex(where: { $0.name == tagMatch.name }) {
                    balandedTags.append((openedTags[openingTagIndex], tagMatch))
                    openedTags.removeSubrange(openingTagIndex...)
                }
            }
        }

        let orderedTags = balandedTags.flatMap { [$0.opening, $0.closing] }.sorted()
        var orderedTagsIterator = orderedTags.makeIterator()
        var lastTagMatch: TagMatch? = nil
        var currentTextStyles: [TextStyle] = []
        var components: [StringComponent] = []
        for (index, component) in flatStringComponents.enumerated() {
            var matches: [TagMatch] = []
            if let match = lastTagMatch, match.componentIndex == index {
                matches.append(match)
                lastTagMatch = nil
            }

            while let match = orderedTagsIterator.next() {
                if match.componentIndex == index {
                    matches.append(match)
                } else {
                    lastTagMatch = match
                }
            }

            let newComponents = component.split(matches, currentTextStyles: &currentTextStyles)
            components.append(contentsOf: newComponents)
        }

        return SemanticString(components: components)
    }
}

public extension SemanticString {
    init(xmlResource: StringResourceType, args: CVarArg..., styles: [TextStyle] = []) {
        self.init(xml: SemanticString(resource: xmlResource, argsArray: args, styles: styles))
    }
}

public extension SemanticString.StringInterpolation {
    mutating func appendInterpolation(xml string: SemanticString) {
        appendInterpolation(SemanticString(xml: string))
    }
}

private extension SemanticString {
    struct FlatStringComponent {
        var styles: [TextStyle]
        var content: FlatContent
    }

    enum FlatContent {
        case plain(String)
        case attributed(NSAttributedString)
    }
}

private extension SemanticString.StringComponent {
    func mapToFlatStringComponent(localeInfo: LocaleInfoType) -> [SemanticString.FlatStringComponent] {
        let content: SemanticString.FlatContent
        switch self.content {
        case let .plain(string):
            content = .plain(string)

        case let .attributed(string):
            content = .attributed(string)

        case let .localizable(resource, args):
            let format = localeInfo.localize(resource)
            content = .plain(String(format: format, arguments: args))

        case let .dynamic(provider):
            let components = provider(localeInfo).components
            var flatComponents = components.flatMap { component in component.mapToFlatStringComponent(localeInfo: localeInfo) }
            for index in flatComponents.startIndex..<flatComponents.endIndex {
                flatComponents[index].styles = styles + flatComponents[index].styles
            }

            return flatComponents
        }

        return [SemanticString.FlatStringComponent(styles: styles, content: content)]
    }
}

private struct TagMatch {
    let name: String
    let range: NSRange
    let isOpening: Bool
    let componentIndex: Int
}

extension TagMatch: Comparable {
    static func < (lhs: TagMatch, rhs: TagMatch) -> Bool {
        (lhs.componentIndex, lhs.range.location) < (rhs.componentIndex, rhs.range.location)
    }
}

private let tagRegex = try! NSRegularExpression(pattern: "<\\/?([^<>\\s/]*)>", options: [])

private extension SemanticString.FlatContent {
    func getTags(componentIndex: Int) -> [TagMatch] {

        let string: String
        switch self {
        case let .plain(plainString):
            string = plainString

        case let .attributed(attributedString):
            string = attributedString.string
        }

        let nsString = string as NSString

        let range = NSRange(location: 0, length: nsString.length)
        let matches = tagRegex.matches(in: string, options: [], range: range)
        let tagMatches: [TagMatch] = matches.map { match in
            let nameRange = match.range(at: 1)
            return TagMatch(name: nsString.substring(with: nameRange),
                            range: match.range,
                            isOpening: nameRange.length + 2 == match.range.length,
                            componentIndex: componentIndex)
        }

        return tagMatches
    }
}

private extension SemanticString.FlatStringComponent {
    func split(_ tagMatches: [TagMatch], currentTextStyles: inout [SemanticString.TextStyle]) -> [SemanticString.StringComponent] {
        switch content {
        case let .plain(string):
            return splitString(string, tagMatches, &currentTextStyles)

        case let .attributed(string):
            return splitAttributedString(string, tagMatches, &currentTextStyles)
        }
    }

    private func splitString(
        _ string: String,
        _ tagMatches: [TagMatch],
        _ currentTextStyles: inout [SemanticString.TextStyle])
        -> [SemanticString.StringComponent] {

            var components: [SemanticString.StringComponent] = []

            let nsString = string as NSString
            var beginIndex = 0

            for match in tagMatches {
                let textStyle = SemanticString.TextStyle(rawValue: match.name)
                let substring = nsString.substring(with: NSRange(location: beginIndex, length: match.range.location - beginIndex))
                if !substring.isEmpty {
                    components.append(.init(styles: currentTextStyles + self.styles, content: .plain(substring)))
                }
                if match.isOpening {
                    currentTextStyles.append(textStyle)
                } else if let index = currentTextStyles.lastIndex(of: textStyle) {
                    currentTextStyles.remove(at: index)
                }

                beginIndex = match.range.upperBound
            }

            let lastSubstring = nsString.substring(with: NSRange(location: beginIndex, length: nsString.length - beginIndex))
            if !lastSubstring.isEmpty {
                components.append(.init(styles: currentTextStyles + self.styles, content: .plain(lastSubstring)))
            }

            return components
    }

    private func splitAttributedString(
        _ attributedString: NSAttributedString,
        _ tagMatches: [TagMatch],
        _ currentTextStyles: inout [SemanticString.TextStyle])
        -> [SemanticString.StringComponent] {

            var components: [SemanticString.StringComponent] = []

            let nsString = attributedString.string as NSString
            var beginIndex = 0

            for match in tagMatches {
                let textStyle = SemanticString.TextStyle(rawValue: match.name)
                let substring = attributedString.attributedSubstring(
                    from: NSRange(location: beginIndex, length: match.range.location - beginIndex))
                if substring.length > 0 {
                    components.append(.init(styles: currentTextStyles + self.styles, content: .attributed(substring)))
                }

                if match.isOpening {
                    currentTextStyles.append(textStyle)
                } else if let index = currentTextStyles.lastIndex(of: textStyle) {
                    currentTextStyles.remove(at: index)
                }

                beginIndex = match.range.upperBound
            }

            let lastSubstring = attributedString.attributedSubstring(from: NSRange(location: beginIndex, length: nsString.length - beginIndex))
            if lastSubstring.length > 0 {
                components.append(.init(styles: currentTextStyles + self.styles, content: .attributed(lastSubstring)))
            }

            return components
    }
}

public extension StylizableString where Style: SemanticStringStyleType, Style.Environment: LocaleEnvironmentType {
    init(semantic string: SemanticString) {
        self.init(builder: { style, env in
            .just(string.getAttributedString(for: style, environment: env))
        })
    }

    init<O: ObservableType>(semantic stringObservable: O) where O.E == SemanticString {
        self.init(builder: { style, env in
            stringObservable.map { string in string.getAttributedString(for: style, environment: env) }
        })
    }
}

public extension StylizableString.StringInterpolation
where Style: SemanticStringStyleType, Style.Environment: LocaleEnvironmentType {
    mutating func appendInterpolation(semantic string: SemanticString) {
        appendBuilder { style, env in
            .just(string.getAttributedString(for: style, environment: env))
        }
    }

    mutating func appendInterpolation<O: ObservableType>(semantic stringObservable: O) where O.E == SemanticString {
        appendBuilder { style, env in
            stringObservable.map { string in string.getAttributedString(for: style, environment: env) }
        }
    }
}

public func +(lhs: SemanticString, rhs: SemanticString) -> SemanticString {
    SemanticString(components: lhs.components + rhs.components)
}

public func +(lhs: SemanticString, rhs: String) -> SemanticString {
    SemanticString(components: lhs.components + [.init(styles: [], content: .plain(rhs))])
}

public func +(lhs: String, rhs: SemanticString) -> SemanticString {
    SemanticString(components: [SemanticString.StringComponent(styles: [], content: .plain(lhs))] + rhs.components)
}
