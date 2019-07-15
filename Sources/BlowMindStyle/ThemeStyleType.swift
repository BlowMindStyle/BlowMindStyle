public protocol ThemeStyleType: StyleType {
    associatedtype Theme

    func getResources(from theme: Theme) -> Resources
}

public protocol KeyPathThemeStyleType: ThemeStyleType {
    var resourcesPath: KeyPath<Theme, Resources> { get }
}

public extension KeyPathThemeStyleType {
    func getResources(from theme: Theme) -> Resources {
        theme[keyPath: resourcesPath]
    }
}

public extension ThemeStyleType where Resources == Void {
    func getResources(from theme: Theme) -> Void {
        Void()
    }
}
