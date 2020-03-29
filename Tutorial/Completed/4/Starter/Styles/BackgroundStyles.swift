import UIKit
import BlowMindStyle

extension BackgroundStyle: DefaultStyleType {
    static var `default`: BackgroundStyle {
        .init { _ in
            if #available(iOS 13, *) {
                return BackgroundProperties(color: .systemBackground)
            } else {
                return BackgroundProperties(color: .white)
            }
        }
    }
}
