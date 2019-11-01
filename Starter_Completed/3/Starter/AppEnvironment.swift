import UIKit
import BlowMindStyle

struct AppEnvironment {
    let theme: AppTheme

    init(theme: AppTheme) {
        self.theme = theme
    }
}

extension AppEnvironment: StyleEnvironmentConvertible {
    func toStyleEnvironment(_ traitCollection: UITraitCollection) -> StyleEnvironment<AppTheme> {
        StyleEnvironment(traitCollection: traitCollection, theme: theme, locale: Locale.current)
    }
}
