import UIKit

extension ButtonStyle {
    static var primary: Self {
        .init { env in
            var properties = ButtonProperties()
            properties.backgroundColor = UIColor(named: "PrimaryButtonBackground")?.resolved(with: env.traitCollection)
            properties.cornerRadius = 4
            properties.titleColor = .white
            properties.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: env.traitCollection)
            properties.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            return properties
        }
    }
}
