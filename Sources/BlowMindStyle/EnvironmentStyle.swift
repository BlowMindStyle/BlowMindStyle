import UIKit

/**
 Base class for styles.
 When you add new style type, specify concrete `StyleResources` type (struct that stores resources like colors, fonts, sizes, etc.)

 ```
 final class ButtonStyle<Environment: StyleEnvironmentType>: EnvironmentStyle<ButtonProperties, Environment> { }
 ```
 */
open class EnvironmentStyle<StyleResources, Environment: StyleEnvironmentType>: EnvironmentStyleType {
    public typealias Resources = StyleResources

    private let _getResources: (Environment) -> StyleResources

    /**
     - Parameter getResources: the function that returns resources for the specified environment.
     */
    public init(getResources: @escaping (Environment) -> StyleResources) {
        self._getResources = getResources
    }

    public func getResources(from environment: Environment) -> StyleResources {
        _getResources(environment)
    }
}
