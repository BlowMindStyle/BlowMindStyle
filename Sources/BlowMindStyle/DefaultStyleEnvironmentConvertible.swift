import UIKit

public struct DefaultStyleEnvironmentConvertible: StyleEnvironmentConvertible {
    public init() { }

    public func toStyleEnvironment(_ traitCollection: UITraitCollection) -> StyleEnvironment<NoTheme> {
        StyleEnvironment(traitCollection: traitCollection, theme: NoTheme(), locale: Locale.current)
    }
}
