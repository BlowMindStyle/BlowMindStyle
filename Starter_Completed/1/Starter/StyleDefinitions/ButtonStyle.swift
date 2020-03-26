import UIKit
import BlowMindStyle

struct ButtonProperties {
    var backgroundColor: UIColor?
    var cornerRadius: CGFloat?
    var titleColor: UIColor?
    var font: UIFont?
    var contentEdgeInsets: UIEdgeInsets?
}

final class ButtonStyle<Environment: StyleEnvironmentType>: EnvironmentStyle<ButtonProperties, Environment> { }

extension EnvironmentContext where Element: UIButton {
    var buttonStyle: StylableElement<ButtonStyle<StyleEnvironment>> {
        stylableElement { button, style, resources in
            button.setTitleColor(resources.titleColor, for: .normal)

            let cornerRadius = resources.cornerRadius ?? 0

            if let normalColor = resources.backgroundColor {
                let normalBackground = UIImage.resizableImage(withSolidColor: normalColor, cornerRadius: cornerRadius)

                button.setBackgroundImage(normalBackground, for: .normal)
            } else {
                button.setBackgroundImage(nil, for: .normal)
            }

            button.titleLabel?.font = resources.font ?? UIFont.systemFont(ofSize: UIFont.buttonFontSize)

            button.contentEdgeInsets = resources.contentEdgeInsets ?? .zero
        }
    }

    func apply(style: ButtonStyle<StyleEnvironment>) {
        buttonStyle.apply(style)
    }
}
