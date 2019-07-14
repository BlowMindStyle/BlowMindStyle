public protocol ThemeStyleType: StyleType {
    associatedtype Properties
    associatedtype Theme

    func getProperties(from theme: Theme) -> Properties
}

public protocol KeyPathThemeStyleType: ThemeStyleType {
    var propertiesPath: KeyPath<Theme, Properties> { get }
}

public extension KeyPathThemeStyleType {
    func getProperties(from theme: Theme) -> Properties {
        return theme[keyPath: propertiesPath]
    }
}
