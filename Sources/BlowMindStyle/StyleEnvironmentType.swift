import UIKit

/**
 A type for the environment that has locale
 */
public protocol LocaleEnvironmentType {
    var locale: Locale { get }
}

extension LocaleEnvironmentType {
    public var locale: Locale {
        Locale.current
    }
}

/**
 The type denoting that the environment does not use a theme.
 */
public struct NoTheme: Equatable {
    public init() { }
}

/**
A type for the environment that has a theme
*/
public protocol ThemeEnvironmentType {
    associatedtype Theme: Equatable = NoTheme

    var theme: Theme { get }
}

extension ThemeEnvironmentType where Theme == NoTheme {
    public var theme: NoTheme { NoTheme() }
}

/**
 Defines requirements to environment type which can be used for components styling.
 */
public protocol StyleEnvironmentType: ThemeEnvironmentType, LocaleEnvironmentType {
    /**
     The trait collection that can be used by a style to provide right resources.
     Mostly `traitCollection` taken from view for which the style has applied.
     */
    var traitCollection: UITraitCollection { get }
}

/**
 Default implementation for `StyleEnvironmentType`
 */
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

/**
 The environment type that can be converted to `StyleEnvironmentType`.
 */
public protocol StyleEnvironmentConvertible: LocaleEnvironmentType, ThemeEnvironmentType {
    /**
     Associated style environment type. In most cases `StyleEnvironment<Theme>` can be used. It can be replaced on your custom type to provide additional environment values.
     */
    associatedtype StyleEnvironment: StyleEnvironmentType

    /**
     creates `StyleEnvironment` using specified trait collection, `self.locale` and `self.theme`.

     - Parameter traitCollection: trait collection for the stylable view.

     - Returns: style environment that can be used by styles.
     */
    func toStyleEnvironment(_ traitCollection: UITraitCollection) -> StyleEnvironment
}
