import UIKit
import BlowMindStyle
import RxSwift

public struct ButtonProperties {
    public var backgroundColor: UIColor?
    public var cornerRadius: CGFloat?
    public var titleColor: UIColor?
    public var highlightedTitleColor: UIColor?
    public var font: UIFont?
    public var contentEdgeInsets: UIEdgeInsets?
}

public struct ButtonStyle<Environment: StyleEnvironmentType>: EnvironmentStyleType {
    public typealias Resources = ButtonProperties
    private let _getResources: (Environment) -> Resources

    public init(getResources: @escaping (Environment) -> Resources) {
        self._getResources = getResources
    }

    public func getResources(from environment: Environment) -> Resources {
        _getResources(environment)
    }

    public func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
        EnvironmentChange.ThemeOrUserInterfaceStyle.needUpdate(arg)
    }
}

public extension StylizableElements {
    struct Button<Environment: StyleEnvironmentType> {
        weak var view: UIButton?
    }
}

extension StylizableElements.Button: StylizableElement {
    public func apply(style: ButtonStyle<Environment>, resources: ButtonProperties) {
        guard let button = view else { return }

        button.setTitleColor(resources.titleColor, for: .normal)
        button.setTitleColor(resources.highlightedTitleColor, for: .highlighted)

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

public extension EnvironmentContext where Element: UIButton, Environment: StyleEnvironmentType {
    var buttonStyle: EnvironmentContext<StylizableElements.Button<Environment>, Environment> {
        replacingElement(.init(view: element))
    }

    func apply(style: ButtonStyle<Environment>) -> Disposable {
        buttonStyle.apply(style)
    }
}
