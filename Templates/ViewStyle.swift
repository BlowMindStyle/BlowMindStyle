import UIKit
import BlowMindStyle

public struct <#Component#>Properties {
    <#view properties#>
}

public struct <#Component#>Style<Environment: StyleEnvironmentType>: EnvironmentStyleType {
    public typealias Resources = <#Component#>Properties
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
    struct <#Component#><Environment: StyleEnvironmentType> {
        weak var view: <#View#>?
    }
}

extension StylizableElements.<#Component#>: StylizableElement {
    public func apply(style: <#Component#>Style<Environment>, resources: <#Component#>Properties) {
        guard let view = view else { return }

        <#update view properties#>
    }
}

public extension EnvironmentContext where Element: <#View#>, Environment: StyleEnvironmentType {
    var <#component#>Style: EnvironmentContext<StylizableElements.<#Component#><Environment>, Environment> {
        replacingElement(.init(view: element))
    }
}
