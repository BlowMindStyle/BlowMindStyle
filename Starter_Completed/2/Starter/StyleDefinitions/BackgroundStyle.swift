import UIKit
import BlowMindStyle

struct BackgroundProperties {
    let color: UIColor?
}

final class BackgroundStyle<Environment: StyleEnvironmentType>: EnvironmentStyle<BackgroundProperties, Environment> { }

extension EnvironmentContext where Element: UIView {
    var backgroundStyle: StylableElement<BackgroundStyle<StyleEnvironment>> {
        stylableElement { view, style, resources in
            view.backgroundColor = resources.color
        }
    }
}
