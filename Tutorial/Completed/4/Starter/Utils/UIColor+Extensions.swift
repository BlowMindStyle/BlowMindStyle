import UIKit

extension UIColor {
    func resolved(with traitCollection: UITraitCollection) -> UIColor {
        if #available(iOS 13, *) {
            return self.resolvedColor(with: traitCollection)
        } else {
            return self
        }
    }
}
