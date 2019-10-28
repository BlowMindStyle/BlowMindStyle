import UIKit

public protocol StyleEnvironmentType {
    associatedtype Theme: Equatable = NoTheme

    var traitCollection: UITraitCollection { get }
    var theme: Theme { get }
    var locale: Locale { get }
}

public extension StyleEnvironmentType {
    var traitCollection: UITraitCollection { UITraitCollection() }
    var locale: Locale { Locale.current }
}

public struct NoTheme: Equatable {
    public init() { }
}

public extension StyleEnvironmentType where Theme == NoTheme {
    var theme: NoTheme { NoTheme() }
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

public protocol StyleEnvironmentConvertible {
    associatedtype StyleEnvironment: StyleEnvironmentType

    func toStyleEnvironment(_ traitCollection: UITraitCollection) -> StyleEnvironment
}
