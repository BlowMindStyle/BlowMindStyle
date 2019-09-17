public protocol StyleType {
    associatedtype Resources = Void
}

public protocol DefaultStyleType: StyleType {
    static var `default`: Self { get }
}

public protocol EnvironmentStyleType: StyleType {
    associatedtype Environment
    func getResources(from environment: Environment) -> Resources
}

public protocol TextStyleType: EnvironmentStyleType where Resources: TextAttributesProviderType { }
