import UIKit
import BlowMindStyle

extension BackgroundStyle: DefaultStyleType {
    public static var `default`: Self {
        .init { env in
            var properties = BackgroundProperties()
            if #available(iOS 13, *) {
                properties.color = .systemBackground
            } else {
                properties.color = .white
            }

            return properties
        }
    }
}
