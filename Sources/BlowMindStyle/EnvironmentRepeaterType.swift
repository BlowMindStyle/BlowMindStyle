import Foundation

/**
 A type that can repeat the environment starting from the last one.

 Used for cases when the child view not exists during `CompoundStylableElementType.applyStylesToChildComponents(_:)`.
 For example for collection view cells, table view cells.
 ```
 cell.applyStyles(for: self.environmentRelay)
 ```
 */
public protocol EnvironmentRepeaterType {
    associatedtype Environment
    /**
     `ObservableConvertibleType` that repeats the environment.

     Do not call `accept(_:)` or `setEnvironment(_:)` methods manually.
     */
    var environmentRelay: EnvironmentRelay<Environment> { get }
}

private struct AssociatedObjectKeys {
    static var environmentRelay = "environmentRelay"
}

extension EnvironmentRepeaterType where Self: NSObject {
    public var environmentRelay: EnvironmentRelay<Environment> {
        if let existingRelay = objc_getAssociatedObject(self, &AssociatedObjectKeys.environmentRelay) as? EnvironmentRelay<Environment> {
            return existingRelay
        }

        let relay = EnvironmentRelay<Environment>()
        objc_setAssociatedObject(self, &AssociatedObjectKeys.environmentRelay, relay, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return relay
    }
}
