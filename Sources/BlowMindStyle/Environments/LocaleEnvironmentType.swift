import Foundation

public protocol LocaleInfoType {
    var lprojName: String? { get }
    var locale: Locale { get }
}

public struct LocaleInfo: LocaleInfoType, Hashable {
    public let lprojName: String?
    public let locale: Locale

    public init(locale: Locale, lprojName: String? = nil) {
        self.locale = locale
        self.lprojName = lprojName
    }

    public init(_ localeInfo: LocaleInfoType) {
        self.locale = localeInfo.locale
        self.lprojName = localeInfo.lprojName
    }

    public static var system: LocaleInfo {
        LocaleInfo(locale: Locale.current)
    }
}

public protocol LocaleEnvironmentType {
    associatedtype LocaleInfo: LocaleInfoType
    var localeInfo: LocaleInfo { get }
}

public extension LocaleInfoType {
    func localize(_ resource: StringResourceType) -> String {
        let lprojName = self.lprojName ?? Bundle.main.preferredLocalizations.first

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
