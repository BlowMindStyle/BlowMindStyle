import Foundation
import RxSwift

struct StringResourceFormatter<Style, Properties>: StylizableStringComponentType {
    let resource: StringResourceType
    private let argsFactory: (String, Style, @escaping (Style) -> Properties) -> Observable<[NSAttributedString]>

    init(resource: StringResourceType, args: [StylizableStringArgument<Style, Properties>]) {
        self.resource = resource
        if args.isEmpty {
            self.argsFactory = { _, _, _ in .just([]) }
        } else {
            self.argsFactory = { locale, style, properties in
                Observable.zip(args.map { $0.buildAttributedString(locale: locale, style: style, propertiesProvider: properties) })
            }
        }
    }

    func buildAttributedString(locale: String, style: Style, propertiesProvider: @escaping (Style) -> Properties) -> Observable<NSAttributedString> {
        let string = getLocalizedString(for: locale)
        let stringParts = splitString(string)
        return argsFactory(locale, style, propertiesProvider).map { args in
            Self.localize(stringParts, with: args)
        }
    }

    private func getLocalizedString(for locale: String) -> NSString {
        guard let languageBundlePath = resource.bundle.path(forResource: locale, ofType: "lproj"),
            let languageBundle = Bundle(path: languageBundlePath) else {
                return resource.bundle.localizedString(forKey: resource.key, value: nil, table: resource.tableName) as NSString
        }

        return languageBundle.localizedString(forKey: resource.key, value: nil, table: resource.tableName) as NSString
    }

    private func splitString(_ string: NSString) -> [String] {
        let formatSpecifiers = "(%@)|(%d)|(%x)|(%o)|(%ld)|(%lx)|(%lu)|(%f)|(%e)|(%g)|(%c)|(%s)|(%a)"
        let regex = try! NSRegularExpression(pattern: formatSpecifiers, options: .caseInsensitive)
        let matches = regex.matches(in: string as String, options: [], range: NSMakeRange(0, string.length))

        var result: [String] = []
        result.reserveCapacity(matches.count + 1)

        var prevMatchEnd = 0
        for match in matches {
            result.append(string.substring(with: NSMakeRange(prevMatchEnd, match.range.lowerBound)))
            prevMatchEnd = match.range.upperBound
        }

        result.append(string.substring(from: prevMatchEnd))
        return result
    }

    private static func localize(_ parts: [String], with args: [NSAttributedString]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        var argsIterator = args.makeIterator()

        for part in parts {
            result.append(NSAttributedString(string: part))
            if let arg = argsIterator.next() {
                result.append(arg)
            }
        }

        return result
    }
}


public extension StylizableString.StringInterpolation {
    mutating func appendInterpolation(resource: StringResourceType, args: StylizableStringArgument<Style, Properties>...) {
        appendComponent(StringResourceFormatter(resource: resource, args: args))
    }
}
