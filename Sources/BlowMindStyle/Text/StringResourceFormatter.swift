import Foundation
import RxSwift

private let regex: NSRegularExpression = {
    let formatSpecifiers = "(%@)|(%d)|(%x)|(%o)|(%ld)|(%lx)|(%lu)|(%f)|(%e)|(%g)|(%c)|(%s)|(%a)"
    return try! NSRegularExpression(pattern: formatSpecifiers, options: .caseInsensitive)
}()

struct StringResourceFormatter<Style: TextStyleType>: StylizableStringComponentType where Style.Environment: LocaleEnvironmentType {
    let resource: StringResourceType
    private let argsFactory: (Style, Style.Environment) -> Observable<[NSAttributedString]>

    init(resource: StringResourceType, args: [StylizableStringArgument<Style>]) {
        self.resource = resource
        if args.isEmpty {
            self.argsFactory = { _, _ in .just([]) }
        } else {
            let renderers = args.map { $0.renderer }
            self.argsFactory = { style, environment in
                Observable.zip(renderers.map { $0.buildAttributedString(style: style, environment: environment) })
            }
        }
    }

    func buildAttributedString(style: Style, environment: Style.Environment) -> Observable<NSAttributedString> {
        let string = getLocalizedString(lprojName: environment.locale.lprojName)
        let stringParts = splitString(string)
        return argsFactory(style, environment).map { args in
            Self.localize(stringParts, with: args)
        }
    }

    private func getLocalizedString(lprojName: String) -> NSString {
        guard let languageBundlePath = resource.bundle.path(forResource: lprojName, ofType: "lproj"),
            let languageBundle = Bundle(path: languageBundlePath) else {
                return resource.bundle.localizedString(forKey: resource.key, value: nil, table: resource.tableName) as NSString
        }

        return languageBundle.localizedString(forKey: resource.key, value: nil, table: resource.tableName) as NSString
    }

    private func splitString(_ string: NSString) -> [String] {
        let matches = regex.matches(in: string as String, options: [], range: NSMakeRange(0, string.length))

        var result: [String] = []
        result.reserveCapacity(matches.count + 1)

        var prevMatchEnd = 0
        for match in matches {
            result.append(string.substring(with: NSMakeRange(prevMatchEnd, match.range.lowerBound - prevMatchEnd)))
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

public extension StylizableString.StringInterpolation where Style.Environment: LocaleEnvironmentType {
    mutating func appendInterpolation(resource: StringResourceType, args: StylizableStringArgument<Style>...) {
        appendComponent(StringResourceFormatter(resource: resource, args: args))
    }
}

public extension StylizableStringArgument where Style.Environment: LocaleEnvironmentType {
    static func resource(_ resource: StringResourceType, args: StylizableStringArgument...) -> Self {
        .init(StringResourceFormatter(resource: resource, args: args))
    }
}
