import UIKit

public struct GenericStyle<StyleResources, Environment, EnvironmentChangeDetector: StyleEnvironmentChangeDetectorType>: EnvironmentStyleType
where EnvironmentChangeDetector.Environment == Environment {
    public typealias Resources = StyleResources

    private let _getResources: (Environment) -> StyleResources
    private let _needUpdate: ((NeedUpdateStyleArgs<Environment>) -> Bool)?

    public init(getResources: @escaping (Environment) -> StyleResources) {
        self._getResources = getResources
        self._needUpdate = nil
    }

    public init(getResources: @escaping (Environment) -> StyleResources, needUpdate: @escaping (NeedUpdateStyleArgs<Environment>) -> Bool) {
        self._getResources = getResources
        self._needUpdate = needUpdate
    }

    public func getResources(from environment: Environment) -> StyleResources {
        _getResources(environment)
    }

    public func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
        if let needUpdate = _needUpdate {
            return needUpdate(arg)
        } else {
            return EnvironmentChangeDetector.needUpdate(arg)
        }
    }
}
