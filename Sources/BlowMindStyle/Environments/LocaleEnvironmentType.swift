import Foundation

public protocol LocaleInfoType {
    var lprojName: String? { get }
    var locale: Locale { get }
}

public protocol LocaleEnvironmentType {
    associatedtype LocaleInfo: LocaleInfoType
    var localeInfo: LocaleInfo { get }
}

public extension LocaleInfoType {
    func localize(_ resource: StringResourceType) -> String {
        guard let languageBundlePath = resource.bundle.path(forResource: lprojName, ofType: "lproj"),
            let languageBundle = Bundle(path: languageBundlePath) else {
                return resource.bundle.localizedString(forKey: resource.key, value: nil, table: resource.tableName)
        }

        return languageBundle.localizedString(forKey: resource.key, value: nil, table: resource.tableName)
    }
}

public struct DefaultLocaleInfo: LocaleInfoType {
    public var lprojName: String? {
        return nil
    }

    public var locale: Locale {
        return .current
    }

    public init() { }
}
