import UIKit
import BlowMindStyle

struct AppEnvironment {
    let theme: AppTheme
}

extension AppEnvironment: StyleEnvironmentConvertible {
    func toStyleEnvironment(_ traitCollection: UITraitCollection) -> StyleEnvironment<AppTheme> {
        StyleEnvironment(traitCollection: traitCollection, theme: theme, locale: locale)
    }
}
