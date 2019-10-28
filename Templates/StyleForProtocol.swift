import UIKit
import BlowMindStyle

public struct <#Component#>Properties {
    <#view properties#>
}

public protocol <#Component#>Type: AnyObject {
    func setProperties(_ properties: <#Component#>Properties)
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
        weak var view: <#Component#>Type?
    }
}

extension StylizableElements.<#Component#>: StylizableElement {
    public func apply(style: <#Component#>Style<Environment>, resources: <#Component#>Properties) {
        view?.setProperties(resources)
    }
}

public extension EnvironmentContext where Element: <#Component#>Type, Environment: StyleEnvironmentType {
    var style: EnvironmentContext<StylizableElements.<#Component#><Environment>, Environment> {
        replacingElement(.init(view: element))
    }
}
