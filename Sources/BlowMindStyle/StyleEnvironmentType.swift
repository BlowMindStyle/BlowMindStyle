import UIKit

public protocol LocaleEnvironmentType {
    var locale: Locale { get }
}

extension LocaleEnvironmentType {
    public var locale: Locale {
        Locale.current
    }
}

public struct NoTheme: Equatable {
    public init() { }
}

public protocol ThemeEnvironmentType {
    associatedtype Theme: Equatable = NoTheme

    var theme: Theme { get }
}

extension ThemeEnvironmentType where Theme == NoTheme {
    public var theme: NoTheme { NoTheme() }
}

public protocol StyleEnvironmentType: ThemeEnvironmentType, LocaleEnvironmentType {
    var traitCollection: UITraitCollection { get }
}

public struct StyleEnvironment<Theme: Equatable>: StyleEnvironmentType {
    public let traitCollection: UITraitCollection
    public let theme: Theme
    public let locale: Locale

    public init(traitCollection: UITraitCollection,
                theme: Theme,
                locale: Locale) {
        self.traitCollection = traitCollection
        self.theme = theme
        self.locale = locale
    }
}

public protocol StyleEnvironmentConvertible: LocaleEnvironmentType, ThemeEnvironmentType {
    associatedtype StyleEnvironment: StyleEnvironmentType

    func toStyleEnvironment(_ traitCollection: UITraitCollection) -> StyleEnvironment
}
