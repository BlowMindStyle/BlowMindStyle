import RxSwift

public protocol StyleType {
    associatedtype Resources = Void
}

public protocol DefaultStyleType: StyleType {
    static var `default`: Self { get }
}

public protocol EnvironmentStyleType: StyleType {
    associatedtype Environment
    func getResources(from environment: Environment) -> Resources
    func needUpdate(latestStyleUpdateEnvironment: Environment, newEnvironment: Environment) -> Bool
}

public extension EnvironmentStyleType {
    func needUpdate(latestStyleUpdateEnvironment: Environment, newEnvironment: Environment) -> Bool {
        true
    }
}

internal extension EnvironmentStyleType {
    func filteredEnvironment(_ environment: Observable<Environment>) -> Observable<Environment> {
        typealias EnvironmentInfo = (env: Environment, skip: Bool)
        let environmentToSkip = environment.scan(Optional<EnvironmentInfo>.none, accumulator: { info, newEnvironment in
            guard let latestStyleUpdateEnvironment = info?.env
                else { return (newEnvironment, false) }

            if self.needUpdate(latestStyleUpdateEnvironment: latestStyleUpdateEnvironment, newEnvironment: newEnvironment) {
                return (newEnvironment, false)
            } else {
                return (latestStyleUpdateEnvironment, true)
            }
        })

        return environmentToSkip.filter { $0?.skip == false }.map { $0!.env }
    }
}

public protocol TextStyleType: EnvironmentStyleType where Resources: TextAttributesProviderType { }
