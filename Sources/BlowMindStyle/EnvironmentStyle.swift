import UIKit

open class EnvironmentStyle<StyleResources, Environment: StyleEnvironmentType>: EnvironmentStyleType {
    public typealias Resources = StyleResources

    private let _getResources: (Environment) -> StyleResources

    public init(getResources: @escaping (Environment) -> StyleResources) {
        self._getResources = getResources
    }

    public func getResources(from environment: Environment) -> StyleResources {
        _getResources(environment)
    }
}
