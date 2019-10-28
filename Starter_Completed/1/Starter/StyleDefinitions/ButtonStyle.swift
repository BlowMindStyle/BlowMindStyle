import UIKit
import BlowMindStyle
import RxSwift

public struct ButtonProperties {
    public var backgroundColor: UIColor?
    public var cornerRadius: CGFloat?
    public var titleColor: UIColor?
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

        button.layer.cornerRadius = resources.cornerRadius ?? 0
        button.setTitleColor(resources.titleColor, for: .normal)

        let cornerRadius = resources.cornerRadius ?? 0

        if let normalColor = resources.backgroundColor {
            let normalBackground = UIImage.resizableImage(withSolidColor: normalColor, cornerRadius: cornerRadius)

            button.setBackgroundImage(normalBackground, for: .normal)
        }

        if let font = resources.font {
            button.titleLabel?.font = font
        }

        if let contentEdgeInsets = resources.contentEdgeInsets {
            button.contentEdgeInsets = contentEdgeInsets
        }
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
