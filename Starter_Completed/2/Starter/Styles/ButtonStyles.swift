import UIKit

extension ButtonStyle where Environment.Theme == AppTheme {
    static var primary: Self {
        .init { env in
            var properties = ButtonProperties()
            properties.backgroundColor = env.theme.primaryBackgroundColor?.resolved(with: env.traitCollection)
            properties.cornerRadius = 4
            properties.titleColor = .white
            properties.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: env.traitCollection)
            properties.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            return properties
        }
    }
}

extension AppTheme {
    var primaryBackgroundColor: UIColor? {
        switch self {
        case .theme1:
            return UIColor(named: "PrimaryButtonBackground")

        case .theme2:
            return UIColor(named: "PrimaryButtonBackgroundGreen")
        }
    }
}
