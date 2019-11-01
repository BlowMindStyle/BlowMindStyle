import UIKit
import BlowMindStyle

public struct BackgroundProperties {
    public var color: UIColor?
}

public struct BackgroundStyle<Environment: StyleEnvironmentType>: EnvironmentStyleType {
    public typealias Resources = BackgroundProperties
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
    struct Background<Environment: StyleEnvironmentType> {
        weak var view: UIView?
    }
}

extension StylizableElements.Background: StylizableElement {
    public func apply(style: BackgroundStyle<Environment>, resources: BackgroundProperties) {
        guard let view = view else { return }

        view.backgroundColor = resources.color
    }
}

public extension EnvironmentContext where Element: UIView, Environment: StyleEnvironmentType {
    var backgroundStyle: EnvironmentContext<StylizableElements.Background<Environment>, Environment> {
        replacingElement(.init(view: element))
    }
}
