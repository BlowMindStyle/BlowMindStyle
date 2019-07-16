public protocol StyleType {
    associatedtype Resources = Void
    static var `default`: Self { get }
}

public protocol EnvironmentStyleType: StyleType {
    associatedtype Environment
    func getResources(from environment: Environment) -> Resources
}
