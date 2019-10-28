import UIKit

extension UITraitCollection {
    var isDarkMode: Bool {
        if #available(iOS 12, *) {
            return userInterfaceStyle == .dark
        } else {
            return false
        }
    }
}
