import UIKit

extension ButtonStyle where Environment.Theme == AppTheme {
    static var primary: ButtonStyle {
        .init { env in
            var properties = ButtonProperties()

            let colorName: String = {
                switch env.theme {
                case .theme1:
                    return "PrimaryButtonBackground"

                case .theme2:
                    return "PrimaryButtonBackground2"
                }
            }()

            properties.backgroundColor = UIColor(named: colorName)
            properties.cornerRadius = 4
            properties.titleColor = .white
            properties.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: env.traitCollection)
            properties.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            return properties
        }
    }
}

extension ButtonStyle {
    static var simple: ButtonStyle {
        .init { env in
            var properties = ButtonProperties()
            let color = UIColor(named: "PrimaryButtonBackground")
            properties.titleColor = color
            properties.highlightedTitleColor = color?.withAlphaComponent(0.5)
            return properties
        }
    }
}
